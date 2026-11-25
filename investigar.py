"""Evidence collection for the local ROM; never edits the game or player saves."""
from pathlib import Path
import hashlib
import json
import urllib.request
import sys
import zlib
import io
import zipfile
import urllib.error

ROOT = Path(__file__).resolve().parent
def save_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')

def identity():
    manifest = json.loads((ROOT/'test/project.json').read_text())
    def resolve(value):
        path = Path(value)
        return path if path.is_absolute() else ROOT / path
    rom = resolve(manifest['rom_path'])
    data = rom.read_bytes()
    header = len(data) % 0x8000
    base = header + 0xffc0
    h = data[base:base+64]
    info = dict(file=rom.name, size=len(data), sha256=hashlib.sha256(data).hexdigest(),
                crc32=f'{zlib.crc32(data):08X}', copier_header_bytes=header,
                title=h[:21].decode('ascii', errors='replace'), header_hex=h.hex(),
                map_mode=f'{h[21]:02X}', cartridge_type=f'{h[22]:02X}',
                rom_size_exponent=h[23], sram_size_exponent=h[24],
                region=h[25], revision=h[27], reset_vector=f'{int.from_bytes(h[60:62], "little"):04X}',
                checksum_stored=f'{int.from_bytes(h[30:32], "little"):04X}',
                checksum_complement=f'{int.from_bytes(h[28:30], "little"):04X}',
                checksum_calculated=f'{sum(data[header:]) & 0xffff:04X}')
    save_json(ROOT/'evidence/rom-identity.json', info)
    protected = [rom]
    source = resolve(manifest['emulator_dir'])
    protected += [p for p in source.rglob('*') if p.is_file() and
                  (p.suffix.lower() in ('.srm', '.000', '.001', '.conf', '.lua') or
                   p.name in ('snes9x.exe', 'lua51.dll', 'lua5.1.dll'))]
    protected += list(ROOT.parent.glob('*.srm'))
    result = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in protected}
    before = ROOT/'evidence/protected-before.json'
    if not before.exists():
        save_json(before, result)
    else:
        old = json.loads(before.read_text(encoding='utf-8'))
        save_json(ROOT/'evidence/integrity-after.json', dict(
            checked=len(old), changed=[p for p, sha in old.items() if result.get(p) != sha],
            added=[p for p in result if p not in old]))
    print(json.dumps(info, indent=2))

def get(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'SM-access-research'})
    with urllib.request.urlopen(req, timeout=60) as response:
        return response.read()

def sources():
    repo = 'cidwel/som-decomp'
    commit = json.loads(get(f'https://api.github.com/repos/{repo}/commits/main'))['sha']
    names = ['text', 'wram-companion-map', 'weapons-melee', 'weapons-ranged',
             'rom-combat', 'rabite', 'maps', 'hero-movement', 'event-dialogue-font-parser',
             'event-menu-ring-selection', 'event-menu-ring-lifecycle',
             'actor-attack-entry', 'actor-controller-cycle', 'map-control-frame']
    names += ['event-dialogue-pause','event-dialogue-window-state',
              'event-dialogue-line-completion','event-dialogue-window-close',
              'event-menu-general','event-menu-name-helpers', 'event-menu-controller',
              'event-menu-state-api', 'event-menu-coordinates', 'cutscene-engine']
    index = []
    folder = ROOT/'references/som-decomp'
    folder.mkdir(parents=True, exist_ok=True)
    for name in names:
        url = f'https://raw.githubusercontent.com/{repo}/{commit}/docs/{name}.md'
        cached=folder/(name+'.md')
        payload = cached.read_bytes() if cached.exists() else get(url)
        (folder/(name+'.md')).write_bytes(payload)
        index.append(dict(url=url, sha256=hashlib.sha256(payload).hexdigest()))
        print(name, len(payload), flush=True)
    for name in ['event_menu_controller','event_menu_state_api','event_menu_name_helpers',
                 'event_dialogue_line_completion','event_dialogue_window_state','map_tables']:
        target=folder/(name+'.py')
        url=f'https://raw.githubusercontent.com/{repo}/{commit}/tools/{name}.py'
        try:
            payload=target.read_bytes() if target.exists() else get(url)
        except urllib.error.HTTPError as error:
            if error.code != 404:
                raise
            print('Not published:',name,flush=True)
            continue
        target.write_bytes(payload)
        index.append(dict(url=url,sha256=hashlib.sha256(payload).hexdigest()))
    tree=json.loads(get(f'https://api.github.com/repos/{repo}/git/trees/{commit}?recursive=1'))
    save_json(ROOT/'references/som-tree.json',tree)
    print('Menu source paths:',[x['path'] for x in tree['tree'] if any(t in x['path'].lower() for t in ['c01d97','c028a6','c02985','c034','menu_controller'])][:30])
    selected=['initialize_native_menu_page_state_and_record_pointer','initialize_native_party_name_entry_records',
              'append_selected_native_name_glyph','delete_native_name_glyph_on_new_left_button',
              'confirm_native_title_selection_on_changed_pad_zero',
              'construct_native_title_page_short_call_wrapper',
              'confirm_native_name_and_initialize_hero',
              'construct_native_hero_name_screen_with_party_graphics_and_cursor',
              'clear_and_publish_native_name_entry_tile_pair']
    for name in selected:
        url=f'https://raw.githubusercontent.com/{repo}/{commit}/src/rom/{name}.s'
        target=folder/(name+'.s')
        payload=target.read_bytes() if target.exists() else get(url)
        target.write_bytes(payload)
        index.append(dict(url=url,sha256=hashlib.sha256(payload).hexdigest()))
    (folder/'LICENSE').write_bytes(get(f'https://raw.githubusercontent.com/{repo}/{commit}/LICENSE'))
    release = json.loads(get('https://api.github.com/repos/GADeuvall2000/Zelda1Access/releases/tags/Zelda1Accessv2.1'))
    save_json(ROOT/'references/zelda-release.json', release)
    save_json(ROOT/'references/sources.json', dict(commit=commit, documents=index))
    print('Zelda assets:', [(x['name'], x['size'], x['browser_download_url']) for x in release['assets']])

def zelda():
    url = 'https://github.com/user-attachments/files/27719823/Zelda1.Access.v2.1.zip'
    payload = get(url)
    folder = ROOT/'references/zelda1access-v2.1'
    folder.mkdir(parents=True, exist_ok=True)
    entries = []
    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        for entry in archive.infolist():
            entries.append(dict(name=entry.filename, size=entry.file_size))
            p = Path(entry.filename)
            if p.suffix.lower() not in ('.lua', '.py', '.txt', '.md', '.cs', '.json'):
                continue
            target = (folder/p).resolve()
            if not target.is_relative_to(folder.resolve()) or entry.file_size > 5_000_000:
                raise ValueError('Unsafe archive entry')
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(entry))
    save_json(ROOT/'references/zelda-archive.json', dict(url=url,
        sha256=hashlib.sha256(payload).hexdigest(), entries=entries))
    print('Zelda archive indexed; extracted code and documentation only', len(entries))

if __name__ == '__main__':
    if '--sources' in sys.argv:
        sources()
    elif '--zelda' in sys.argv:
        zelda()
    else:
        identity()
