"""Back up the research unit, excluding ROMs, saves and the emulator installation."""
from pathlib import Path
import hashlib
import json
import zipfile
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('--name',default='investigacion-inicial')
name=parser.parse_args().name
if not name or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-' for c in name):
    raise ValueError('Use a simple backup identifier')
root=Path(__file__).resolve().parent
paths=[]
for folder in ('documentacion','source','runtime','evidence'):
    paths.extend(p for p in (root/folder).rglob('*') if p.is_file() and p.name!='backup.json')
paths.extend(root.glob('*.py'))
paths.extend(root.glob('*.md'))
for pattern in ('*.lua','*.ps1','*.cmd'):
    paths.extend(root.glob(pattern))
paths.append(root/'.gitignore')
paths.extend(p for p in (root/'test').iterdir() if p.is_file())
for case in ('smoke-check','research-check','native-start-check','reader01-check','boot-reader01-check','walls03-check','proximity05-check','pendientes06-check','terreno06-check','terreno06b-check','terreno06c-check','profile07-check','profile07b-check','profile07c-check','profile07d-check','travel07-check','cuttable08-check','potos09-research','potos09-check','potos09b-check'):
    paths.extend(p for p in (root/'test'/case).iterdir() if p.is_file())
    paths.extend(p for p in (root/'test'/case/'frozen').rglob('*') if p.is_file())
paths.extend(p for p in (root/'test/fixtures').rglob('*') if p.is_file())
paths.extend([root/'references/sources.json',root/'references/zelda-release.json',root/'references/zelda-archive.json'])
paths=sorted(set(paths))
backup=root/('backups/'+name+'.zip')
backup.parent.mkdir(exist_ok=True)
if backup.exists():
    raise ValueError('Backup already exists; preserve it and choose a new name')
entries=[]
with zipfile.ZipFile(backup,'w',compression=zipfile.ZIP_DEFLATED) as archive:
    for p in paths:
        if p.suffix.lower() in ('.smc','.sfc','.srm'):
            raise ValueError('Private game data cannot enter this backup')
        relative=p.relative_to(root).as_posix()
        data=p.read_bytes()
        archive.writestr(relative,data)
        entries.append(dict(path=relative,sha256=hashlib.sha256(data).hexdigest()))
with zipfile.ZipFile(backup) as archive:
    assert archive.testzip() is None
result=dict(path=str(backup.relative_to(root)),sha256=hashlib.sha256(backup.read_bytes()).hexdigest(),files=entries)
(root/'evidence').mkdir(parents=True,exist_ok=True)
(root/('evidence/backup-'+name+'.json')).write_text(json.dumps(result,indent=2),encoding='utf-8')
print('Verified backup:',len(entries),'files;',backup.stat().st_size,'bytes')
