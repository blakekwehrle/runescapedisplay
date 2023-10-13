load("cache.star", "cache")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("random.star", "random")
load("render.star", "render")
load("schema.star", "schema")

CACHE_TTL_SECONDS = 36604800 # 7 days in seconds.
RUNESCAPEAPI_ITEMLIST_URL = "https://secure.runescape.com/m=itemdb_oldschool/api/catalogue/items.json?category=1&alpha={0}&page={1}"
RUNESCAPEAPI_ITEMSPRITE_URL = "https://secure.runescape.com/m=itemdb_oldschool/1696847772651_obj_sprite.gif?id={0}}"
PAGE_LENGTH_BY_LETTER = { 'a': 30, 'b': 40, 'c': 16, 'd': 20, 'e': 11, 'f': 8, 'g': 18, 'h': 5,
                          'i': 10, 'j': 4, 'k': 4, 'l': 7, 'm': 25, 'n': 3, 'o': 9, 'p': 13,
                          'r': 25, 's': 44, 't': 22, 'u': 5, 'v': 5, 'w': 11, 'x': 1, 'y': 3, 'z': 5}

def main():
    random_letter_index = random.number(0, 24)
    random_letter = 'abcdefghijklmnoprstuvwxyz'[random_letter_index]
    item_list = get_item_list(random_letter)
    number_of_items = len(item_list["items"])
    random_item_index = random.number(0, number_of_items-1)
    title = item_list["items"][random_item_index]["name"]
    item_name = title
    sprite_url = item_list["items"][random_item_index]["icon"]
    sprite = get_cachable_data(sprite_url)
    return render.Root(
        child = render.Stack(
            children = [
                render.Row(
                    children = [
                        render.Box(width = 32),
                        render.Box(render.Image(sprite)),
                    ],
                ),
                render.Column(
                    children = [
                        render.WrappedText (
                            content=item_name,
                            width=64,
                            font="tom-thumb",
                        )
                    ],
                ),
            ],
        ),
    )

def get_item_list(letter):
    url = RUNESCAPEAPI_ITEMLIST_URL.format(letter, random.number(0, PAGE_LENGTH_BY_LETTER[letter]))
    data = get_cachable_data(url)
    return json.decode(data)
    
def get_cachable_data(url, ttl_seconds = CACHE_TTL_SECONDS):
    key = base64.encode(url)

    data = cache.get(key)
    if data != None:
        return base64.decode(data)

    res = http.get(url = url)
    if res.status_code != 200:
        fail("request to %s failed with status code: %d - %s" % (url, res.status_code, res.body()))

    cache.set(key, base64.encode(res.body()), ttl_seconds = ttl_seconds)

    return res.body()