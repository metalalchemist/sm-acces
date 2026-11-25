"""Copy existing authorized support assets; never loads a DLL or plays audio."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import wave

root = Path(__file__).resolve().parent
origin = root.parent/'chrono-access'
runtime = root/'runtime'
runtime.mkdir(exist_ok=True)
records=[]
inputs = list((origin/'runtime/sounds').glob('*.wav'))
inputs += [origin/'runtime'/n for n in ('chrono_audio.dll','chrono_prism_v2.dll','prism.dll')]
inputs += [origin/n for n in ('chrono_audio.cpp','chrono_prism.cpp')]
for source in inputs:
    relative = Path('sounds')/source.name if source.suffix=='.wav' else Path(source.name)
    target = runtime/relative
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest()!=digest:
        raise ValueError(f'Refusing to overwrite changed asset: {target}')
    target.parent.mkdir(exist_ok=True)
    shutil.copy2(source,target)
    record=dict(source=str(source),local=str(target.relative_to(root)),sha256=digest)
    if source.suffix=='.wav':
        with wave.open(str(source),'rb') as audio:
            record.update(channels=audio.getnchannels(), sample_rate=audio.getframerate(),
                bits=audio.getsampwidth()*8, frames=audio.getnframes(),
                seconds=audio.getnframes()/audio.getframerate())
    elif source.suffix=='.dll':
        data=source.read_bytes()
        pe=struct.unpack_from('<I',data,0x3c)[0]
        record['pe_machine']=f'{struct.unpack_from("<H",data,pe+4)[0]:04X}'
    records.append(record)
(runtime/'assets.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
print(f'Copied {len(records)} support assets; no audio activation')
