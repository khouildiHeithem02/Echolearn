import urllib.request, json, time, os

headers = {'User-Agent': 'EchoLearnApp/1.0 (mmehd@example.com)'}
files_to_try = {
    'cat.ogg': ['File:Meow.ogg', 'File:Kitten_meow.ogg'],
    'dog.ogg': ['File:Dog_bark.ogg', 'File:Puppy_bark.ogg'],
    'bird.ogg': ['File:Bird_chirping.ogg', 'File:Birds_singing.ogg', 'File:Chiffchaff_song.ogg'],
    'cow.ogg': ['File:Cow_moo.ogg', 'File:Moo.ogg'],
    'duck.ogg': ['File:Ducks_Quacking.ogg'],
    'train.ogg': ['File:Train_horn.ogg', 'File:Train_whistle.ogg'],
    'bike.ogg': ['File:Bicycle_bell.ogg', 'File:Bike_bell.ogg'],
    'rain.ogg': ['File:Rain_sound.ogg', 'File:Rain.ogg', 'File:Heavy_rain.ogg'],
    'stream.ogg': ['File:Water_flowing.ogg', 'File:River.ogg', 'File:Stream_water.ogg']
}

os.makedirs('assets/audio', exist_ok=True)

for local_name, wiki_names in files_to_try.items():
    titles = '|'.join(wiki_names)
    url = f'https://commons.wikimedia.org/w/api.php?action=query&titles={titles}&prop=imageinfo&iiprop=url&format=json'
    req = urllib.request.Request(url, headers=headers)
    try:
        resp = urllib.request.urlopen(req)
        data = json.loads(resp.read().decode())
        pages = data['query']['pages']
        downloaded = False
        for page_id, page_info in pages.items():
            if int(page_id) > 0 and 'imageinfo' in page_info:
                audio_url = page_info['imageinfo'][0]['url']
                print(f'Downloading {local_name} from {audio_url}')
                audio_req = urllib.request.Request(audio_url, headers=headers)
                audio_resp = urllib.request.urlopen(audio_req)
                with open(f'assets/audio/{local_name}', 'wb') as f:
                    f.write(audio_resp.read())
                downloaded = True
                break
        if not downloaded:
            print(f'Could not find audio for {local_name}')
    except Exception as e:
        print(f'Failed for {local_name}: {e}')
    time.sleep(1)
