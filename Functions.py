import requests
from bs4 import BeautifulSoup
from datetime import datetime


def get_ad(singular_ad):
    """
    (element) --> list

    Returns a list that includes the title, price, and individual URL of a singular_ad listed on Olx.

    >>>get_ad_info('www.fakegoogletest.com')
    ['Car for Sale', '5000', 'www.fakegoogletest.com/?item=car']


    """

    info_ad = singular_ad.find('div', class_='ads__item__info')
    url_ad = singular_ad['data-adurl']
    if 'lb/en/' not in url_ad:
        url_ad = url_ad[:22] + '/en' + url_ad[22:]
    title_ad = info_ad.find('a', class_='ads__item__ad--title')['title'].strip()

    try:
        price_ad = str(info_ad.find('p', class_='ads__item__price price').text.strip())
        price_ad = int(price_ad.strip(' USD').replace(',', ''))
    except ValueError:
        price_ad = int(info_ad.find('p', class_='ads__item__price price').text.split(' ')[0].replace(',', '').replace('\n\t', ''))

    lst = [title_ad, price_ad, url_ad]

    return lst


def save_ads(file_name):
    """
    Returns a .txt file named file_name that contains rows of data about individual olx car listings separated by
    the delimiter '$$$'.

    """

    with open(file_name, 'w', encoding='UTF8') as f:
        head = ['Title', 'Price', 'URL']
        f.write(f'{head[0]}$$${head[1]}$$${head[2]}\n')

        last_page = 1
        i = 1
        while i <= last_page:
            olx = f'https://www.olx.com.lb/en/vehicles/cars-for-sale/?search%5Border%5D=created_at%3Adesc&page={i}'

            headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36'}
            html_text = requests.get(olx, headers=headers).text
            soup = BeautifulSoup(html_text, 'lxml')

            list_ads = soup.find('div', class_='ads ads--list')
            all_ads = list_ads.find_all('div', class_='ads__item')

            pages = soup.find('div', class_='pager rel clr')
            pages_numbers = pages.find_all('a', class_='block br3 brc8 large tdnone lheight24')[-1]
            last_page = int(pages_numbers.text.strip())
            i += 1

            for singular_ad in all_ads:
                ad = get_ad(singular_ad)
                f.write(f'{ad[0]}$$${ad[1]}$$${ad[2]}\n')

        f.write('end')

    return f


def get_ad_info(html_text):

    soup = BeautifulSoup(html_text, 'lxml')
    ad_body = soup.find('div', class_='clr offerbody')
    ad_top_body = soup.find('div', class_='rel breadcrumbbox')
    ad_subsection = ad_top_body.find_all('a', class_='link nowrap')[-1]
    ad_footer = ad_body.find_all('div', class_='pdingtop10')

    ad_id = ad_body.find('span', class_='rel inlblk').text.strip()
    ad_date = ad_body.find('span', class_='pdingleft10 brlefte5').text.split(', ')[1].strip()
    ad_date = datetime.strptime(ad_date, '%d %B %Y').strftime('%Y-%m-%d')
    ad_title = ad_body.find('h1', class_='brkword lheight28').text.strip()
    ad_price_value = int(
        ad_body.find('strong', class_='xxxx-large margintop7 block not-arranged').text.strip().replace(',', '').replace(
            ' USD', ''))
    advertiser_name = ad_body.find('p', class_='user-box__info__name').text.strip()
    ad_brand = ad_subsection.find('span').text.split(' ')[0]

    table = {}
    ad_info_table = ad_body.find('table', class_='details fixed marginbott20 margintop5 full')
    keys = ad_info_table.find_all('th')
    values = ad_info_table.find_all('td', class_='value')
    for key, value in zip(keys, values):
        key = str(key.text.strip())
        if key == 'Extra Features':
            features = value.find_all('a')
            feature_number = [_['title'].split(' - ')[0].strip() for _ in features]
            table[key] = len(feature_number)
        else:
            value = value.find('a')
            value = value['title'].split(' - ')[0].strip()
            table[key] = value

    if 'Extra Features' not in table:
        table['Extra Features'] = ' '

    if 'Model' not in table:
        table['Model'] = ' '

    tbl = table.items()
    sorted_table = sorted(tbl)


    ad_description_length = len(ad_body.find('p', class_='pding10 lheight20 large').text.strip().replace(' ', ''))
    ad_image_number = len(ad_body.find_all('div', class_='tcenter img-item')) + len(
        ad_body.find_all('div', class_='gallery_img tcenter img-item'))

    ad_views = 0
    for element in ad_footer:
        if 'strong' in str(element):
            ad_views = int(element.find('strong').text.strip())

    sub_lst1 = [ad_id, ad_date, ad_title, ad_price_value, advertiser_name, ad_description_length,
           ad_image_number, ad_views]
    sub_lst2 = [ad_id, ad_brand, sorted_table]

    lst = [sub_lst1, sub_lst2]

    return lst



