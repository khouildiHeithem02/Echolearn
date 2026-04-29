import urllib.request, json, time, os

headers = {'User-Agent': 'EchoLearnApp/1.0'}
queries = {'cat': 'cat.mp3', 'bird': 'bird.mp3', 'cow': 'cow.mp3', 'duck': 'duck.mp3', 'sheep': 'sheep.mp3', 'bike': 'bicycle.mp3', 'train': 'train.mp3', 'rain': 'rain.mp3', 'stream': 'stream.mp3'}

os.makedirs('assets/audio', exist_ok=True)

for name, query in queries.items():
    url = f'https://api.github.com/search/code?q={query}+in:path+extension:mp3'
    try:
        req = urllib.request.Request(url, headers=headers)
        resp = urllib.request.urlopen(req)
        data = json.loads(resp.read().decode())
        if data['items']:
            item = data['items'][0]
            raw_url = item['html_url'].replace('github.com', 'raw.githubusercontent.com').replace('/blob/', '/')
            print(f'Downloading {name} from {raw_url}')
            audio_req = urllib.request.Request(raw_url, headers=headers)
            audio_resp = urllib.request.urlopen(audio_req)
            with open(f'assets/audio/{name}.mp3', 'wb') as f:
                f.write(audio_resp.read())
        else:
            print(f'No results for {name}')
    except Exception as e:
        print(f'Failed {name}: {e}')
    time.sleep(3)
