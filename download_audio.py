import urllib.request
import os
import time

os.makedirs('assets/audio', exist_ok=True)

headers = {
    'User-Agent': 'EcholearnEducationalApp/1.0 (Arabic speech learning app for children; educational use)'
}

# Different URLs to try
urls = {
    'cat': [
        'https://www.soundsnap.com/files/audio/segments/cat_meow_9_SLFX.mp3',
        'https://upload.wikimedia.org/wikipedia/commons/f/ff/Cat_purr.ogg',
        'https://upload.wikimedia.org/wikipedia/commons/e/ee/Cat_meow.ogg',
    ],
    'waves': [
        'https://upload.wikimedia.org/wikipedia/commons/9/95/Surf_on_a_rocky_shore.ogg',
    ],
    'car': [
        'https://upload.wikimedia.org/wikipedia/commons/1/1a/Car_horn_1.ogg',
        'https://upload.wikimedia.org/wikipedia/commons/4/43/Car_Alarm.ogg',
    ],
    'wind': [
        'https://upload.wikimedia.org/wikipedia/commons/0/09/Wind_80_mph.ogg',
    ],
    'thunder': [
        'https://upload.wikimedia.org/wikipedia/commons/c/c4/Thunder_Storm_on_7-30-09.ogg',
    ],
    'cow': [
        'https://upload.wikimedia.org/wikipedia/commons/e/e6/Cow_moo.ogg',
    ],
}

for name, url_list in urls.items():
    out_path = f'assets/audio/{name}.ogg'
    if os.path.exists(out_path) and os.path.getsize(out_path) > 1000:
        print(f'Skipping {name} (already exists, {os.path.getsize(out_path)} bytes)')
        continue
    
    for url in url_list:
        try:
            time.sleep(2)  # be polite
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=20) as response, open(out_path, 'wb') as out_file:
                data = response.read()
                out_file.write(data)
            print(f'Downloaded {name}: {len(data)} bytes from {url}')
            break
        except Exception as e:
            print(f'  Failed {name} from {url}: {e}')

print('\nFinal files:')
for f in os.listdir('assets/audio'):
    size = os.path.getsize(f'assets/audio/{f}')
    print(f'  {f}: {size} bytes')
