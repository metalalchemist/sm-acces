// Lua 5.1 module. Resolves the emulator's existing Lua DLL: no second Lua VM.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <prism.h>
#include <cstring>

struct lua_State;
using LuaFunction = int (__cdecl *)(lua_State *);
static const char *(__cdecl *checkString)(lua_State *, int, size_t *);
static void (__cdecl *pushBoolean)(lua_State *, int);
static void (__cdecl *pushString)(lua_State *, const char *);
static void (__cdecl *pushClosure)(lua_State *, LuaFunction, int);
static void (__cdecl *setField)(lua_State *, int, const char *);
static void (__cdecl *createTable)(lua_State *, int, int);
static int (__cdecl *luaError)(lua_State *, const char *, ...);
static int (__cdecl *getTop)(lua_State *);
static int (__cdecl *toBoolean)(lua_State *, int);
static PrismContext *context = nullptr;
static PrismBackend *backend = nullptr;
static HMODULE prismModule = nullptr;
#define PRISM_FN(name) static decltype(&name) p_##name
PRISM_FN(prism_config_init);
PRISM_FN(prism_init);
PRISM_FN(prism_shutdown);
PRISM_FN(prism_registry_create_best);
PRISM_FN(prism_backend_free);
PRISM_FN(prism_backend_name);
PRISM_FN(prism_backend_speak);
PRISM_FN(prism_backend_stop);

static void closeVoice() {
    if (backend) { p_prism_backend_free(backend); backend = nullptr; }
    if (context) { p_prism_shutdown(context); context = nullptr; }
}

static int initVoice(lua_State *L) {
    if (!prismModule) {
        HMODULE self = nullptr;
        wchar_t path[32768];
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
            GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            reinterpret_cast<LPCWSTR>(&initVoice), &self);
        DWORD length = GetModuleFileNameW(self, path, 32768);
        if (!length || length >= 32768) return luaError(L, "Ruta del modulo no disponible");
        wchar_t *last = wcsrchr(path, L'\\');
        if (!last) return luaError(L, "Ruta del modulo no valida");
        wcscpy_s(last + 1, 32768 - (last + 1 - path), L"prism.dll");
        prismModule = LoadLibraryExW(path, nullptr, LOAD_WITH_ALTERED_SEARCH_PATH);
        if (!prismModule) return luaError(L, "No se pudo cargar prism.dll: Windows %d", GetLastError());
    }
#define RESOLVE(name) p_##name = reinterpret_cast<decltype(p_##name)>(GetProcAddress(prismModule, #name)); \
    if (!p_##name) return luaError(L, "Prism no exporta " #name)
    RESOLVE(prism_config_init);
    RESOLVE(prism_init);
    RESOLVE(prism_shutdown);
    RESOLVE(prism_registry_create_best);
    RESOLVE(prism_backend_free);
    RESOLVE(prism_backend_name);
    RESOLVE(prism_backend_speak);
    RESOLVE(prism_backend_stop);
#undef RESOLVE
    if (!context) {
        PrismConfig config = p_prism_config_init();
        context = p_prism_init(&config);
        if (!context) return luaError(L, "Prism no pudo inicializarse");
        backend = p_prism_registry_create_best(context);
        if (!backend) { closeVoice(); return luaError(L, "Prism no encontro una salida de voz"); }
    }
    pushString(L, p_prism_backend_name(backend));
    return 1;
}

static int speak(lua_State *L) {
    size_t length;
    const char *text = checkString(L, 1, &length);
    if (memchr(text, '\0', length)) return luaError(L, "El texto contiene un byte nulo");
    if (!backend) return luaError(L, "Inicializa Prism antes de hablar");
    const bool interrupt = getTop(L) < 2 || toBoolean(L, 2) != 0;
    PrismError result = p_prism_backend_speak(backend, text, interrupt);
    if (result != PRISM_OK) return luaError(L, "Prism no pudo hablar: error %d", result);
    pushBoolean(L, 1);
    return 1;
}

static int stop(lua_State *L) {
    pushBoolean(L, !backend || p_prism_backend_stop(backend) == PRISM_OK);
    return 1;
}

static int shutdownVoice(lua_State *) { closeVoice(); return 0; }

extern "C" __declspec(dllexport) int luaopen_chrono_prism(lua_State *L) {
    HMODULE lua = GetModuleHandleW(L"lua5.1.dll");
    if (!lua) lua = GetModuleHandleW(L"lua51.dll");
    if (!lua) return 0;
#define LUA_FN(var, name) var = reinterpret_cast<decltype(var)>(GetProcAddress(lua, name)); if (!var) return 0
    LUA_FN(checkString, "luaL_checklstring");
    LUA_FN(pushBoolean, "lua_pushboolean");
    LUA_FN(pushString, "lua_pushstring");
    LUA_FN(pushClosure, "lua_pushcclosure");
    LUA_FN(setField, "lua_setfield");
    LUA_FN(createTable, "lua_createtable");
    LUA_FN(luaError, "luaL_error");
    LUA_FN(getTop, "lua_gettop");
    LUA_FN(toBoolean, "lua_toboolean");
#undef LUA_FN
    createTable(L, 0, 4);
    pushClosure(L, initVoice, 0); setField(L, -2, "init");
    pushClosure(L, speak, 0); setField(L, -2, "speak");
    pushClosure(L, stop, 0); setField(L, -2, "stop");
    pushClosure(L, shutdownVoice, 0); setField(L, -2, "shutdown");
    return 1;
}
