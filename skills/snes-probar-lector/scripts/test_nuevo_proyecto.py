"""Scaffolding tests use no installed game, emulator or global configuration."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('scaffold', Path(__file__).with_name('nuevo-proyecto.py'))
scaffold = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scaffold)


class ScaffoldTests(unittest.TestCase):
    def test_each_game_gets_its_own_manager_and_manifest(self):
        with tempfile.TemporaryDirectory(prefix='snes-scaffold-') as tmp:
            for name in ['earthbound-access', 'illusion-access']:
                root = Path(tmp) / name
                scaffold.create_project(root, name)
                manifest = json.loads((root / 'tests/project.json').read_text(encoding='utf8'))
                self.assertEqual(manifest['project_id'], name)
                self.assertIsNone(manifest['rom_path'])
                self.assertTrue((root / 'tests/emulador-pruebas.ps1').is_file())
                self.assertTrue((root / 'tests/test_emulator_manager.py').is_file())
                self.assertTrue((root / 'source').is_dir())

    def test_nonempty_destination_is_never_overwritten(self):
        with tempfile.TemporaryDirectory(prefix='snes-scaffold-') as tmp:
            root = Path(tmp)
            sentinel = root / 'reader.lua'
            sentinel.write_bytes(b'original work')
            with self.assertRaises(ValueError):
                scaffold.create_project(root, 'existing-access')
            self.assertEqual(sentinel.read_bytes(), b'original work')

    def test_rom_identity_is_computed_and_source_is_not_modified(self):
        with tempfile.TemporaryDirectory(prefix='snes-scaffold-') as tmp:
            base = Path(tmp)
            rom = base / 'source.sfc'
            rom.write_bytes(b'local dummy ROM')
            manifest = scaffold.create_project(base / 'new-access', 'new-access', rom)
            self.assertEqual(manifest['rom_sha256'], scaffold.hashlib.sha256(rom.read_bytes()).hexdigest().upper())
            self.assertEqual(rom.read_bytes(), b'local dummy ROM')


if __name__ == '__main__':
    unittest.main()
