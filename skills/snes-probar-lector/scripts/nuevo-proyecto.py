"""Create an independent SNES test project; never overwrite an existing project."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil


def create_project(target, project_id, rom=None, emulator_dir=None, config_template=None):
    target = Path(target).resolve()
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]*', project_id):
        raise ValueError('Usa un identificador como earthbound-access o illusion-access')
    if target.exists() and (not target.is_dir() or any(target.iterdir())):
        raise ValueError('El destino ya contiene archivos; no se sobrescribe')
    inputs = {}
    for key, value, directory in [('rom_path', rom, False),
                                  ('emulator_dir', emulator_dir, True),
                                  ('config_template', config_template, False)]:
        path = Path(value).resolve() if value else None
        if path and not (path.is_dir() if directory else path.is_file()):
            raise ValueError(f'No existe {key}: {path}')
        inputs[key] = str(path) if path else None
    template = Path(__file__).resolve().parents[1] / 'assets/runtime'
    required = ['emulador-pruebas.ps1', 'enable-background.ps1',
                'smoke.lua', 'test_emulator_manager.py']
    for name in required:
        if not (template / name).is_file():
            raise ValueError(f'Falta un recurso de la skill: {name}')
    tests = target / 'tests'
    tests.mkdir(parents=True, exist_ok=True)
    (target / 'source').mkdir(exist_ok=True)
    for name in required:
        shutil.copy2(template / name, tests / name)
    manifest = dict(schema=1, profile='snes9x-lua-1.63-windows',
                    project_id=project_id, **inputs,
                    rom_sha256=hashlib.sha256(Path(rom).read_bytes()).hexdigest().upper() if rom else None)
    (tests / 'project.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n', encoding='utf8')
    (target / 'continuar.md').write_text(
        f'# {project_id}\n\n'
        'Proyecto nuevo. Todavia no hay un lector de este juego.\n'
        'El gestor y smoke.lua solo comprueban el emulador y el aislamiento.\n\n'
        '1. Completar tests/project.json con la ROM local, su SHA-256, el emulador y su configuracion.\n'
        '2. Ejecutar las pruebas del gestor antes de iniciar el emulador.\n'
        '3. Investigar estados y texto del juego; guardar el adaptador y lectores en source/.\n'
        '4. Mantener capturas, casos, resultados y limites dentro de este proyecto.\n', encoding='utf8')
    (target / '.gitignore').write_text(
        '/tests/emulator/\n/tests/emulator-temp/\n/tests/emulator-management.lock\n'
        '/tests/*/Saves/\n/tests/*/Roms/\n/tests/*/Cheats/\n/tests/*/Patches/\n'
        '/tests/*/sessions/\n*.smc\n*.sfc\n*.srm\n__pycache__/\n', encoding='utf8')
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', type=Path)
    parser.add_argument('--id', required=True, dest='project_id')
    parser.add_argument('--rom', type=Path)
    parser.add_argument('--emulator-dir', type=Path)
    parser.add_argument('--config-template', type=Path)
    args = parser.parse_args()
    try:
        manifest = create_project(args.target, args.project_id, args.rom,
                                  args.emulator_dir, args.config_template)
    except ValueError as error:
        parser.error(str(error))
    print(json.dumps(dict(project=str(args.target.resolve()), **manifest), indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
