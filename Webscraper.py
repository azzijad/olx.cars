from Functions import *
import timeit
import time
import random
from datetime import datetime

start = timeit.default_timer()

ad_file_name = 'ad_list.txt'
data_file_name = 'ad_data_list.txt'
car_info_file_name = 'car_info_list.txt'

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36'}

# # We will now scrape all initial listings and save them to a txt file
save_ads(ad_file_name)

# We will now scrape each individual ad to gather the data

with open(ad_file_name, 'r', encoding='utf-8') as f1:
    lines = f1.readlines()
    olx = [url.split('$$$')[-1].strip() for url in lines
           if url.split('$$$')[-1].strip() != 'URL' and url.split('$$$')[-1].strip() != 'end']

head1 = ['id', 'posted_date', 'title', 'price', 'advertiser', 'description_length', 'image_number', 'views_number']
head2 = ['ad_id', 'ad_brand', 'Body Type', 'Color', 'Extra Features', 'Kilometers', 'Model', 'Transmission Type', 'Year']

with open(data_file_name, 'w', encoding='utf-8') as f2, open(car_info_file_name, 'w', encoding='utf-8') as f3:

    for i in range(len(head1)):
        f2.write(f'{head1[i]}$$$')

    for i in range(len(head2)):
        f3.write(f'{head2[i]}$$$')

    f2.write('\n')
    f3.write('\n')

    for i in range(len(olx)):
        try:
            html_text = requests.get(olx[i], headers=headers, timeout=3).text
        except Exception:
            print('We are Waiting due to connection errors...')
            time.sleep(random.randint(10, 30))
            html_text = requests.get(olx[i], headers=headers, timeout=3).text

        for j in range(len(head2)):
            try:
                if j < 2:
                    f2.write(f'{get_ad_info(html_text)[0][j]}$$$')
                    f3.write(f'{get_ad_info(html_text)[1][j]}$$$')
                elif 2 <= j < len(head1):
                    f2.write(f'{get_ad_info(html_text)[0][j]}$$$')
                    f3.write(f'{get_ad_info(html_text)[1][2][j - 2][-1]}$$$')
                else:
                    f3.write(f'{get_ad_info(html_text)[1][2][j - 2][-1]}$$$')
                    f3.write('\n')
                    f2.write('\n')

            except AttributeError:
                f2.write(f'There was an issue here: {olx[i]}')
                f3.write(f'There was an issue here: {olx[i]}')
                f3.write('\n')
                f2.write('\n')
                break

        print(f'Row number {i} of {len(olx)} has been added.')


# We will now use this part to scrape periodically the ads we have already gathered to monitor the number of views
# as well as the published state of the ad.

with open('ad_update.txt', 'w', encoding='utf-8') as f:

    head = ['id', 'updated_date', 'published', 'views', 'URL']

    for i in range(len(head)):
        f.write(f'{head[i]}$$$')

    f.write('\n')

bad_url = []
with open('ad_update.txt', 'a', encoding='utf-8') as f:
    for i in range(len(olx)):
        try:
            html_text = requests.get(olx[i], headers=headers, timeout=3).text
        except Exception:
            print('We are Waiting due to connection errors...')
            time.sleep(random.randint(10, 30))
            html_text = requests.get(olx[i], headers=headers, timeout=10).text

        try:
            lst = get_ad_info(html_text)
            row = [lst[0][0], datetime.today().strftime('%Y-%m-%d'), 'Yes', lst[0][-1], olx[i]]

        except AttributeError:
            row = ['', datetime.today().strftime('%Y-%m-%d'), 'No', '', olx[i]]
            print('bad row added')
            bad_url.append(olx[i])

        for j in range(len(row)):
            f.write(f'{row[j]}$$$')

        f.write('\n')
        print(f'Row {i} of {len(olx)} has been updated')

# We will now remove all rows that have a URL that leads to an arc  hived ad

index = []

with open('ad_update.txt', 'r', encoding='utf-8') as f:

    for line in lines:
        if line.split('$$$')[2].strip() == 'No':
            bad_url.append(line.split('$$$')[-2].strip())

with open('ad_list.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    for url in bad_url:
        for line in lines:
            if url in line:
                index.append(lines.index(line))
                break

    count = 0
    for i in index:
        lines.pop(i-count)
        count = count + 1

with open('ad_list.txt', 'w', encoding='utf-8') as f:
    for line in lines:
        f.write(line)

stop = timeit.default_timer()
execution_time = stop - start

print("Program Executed in "+str(execution_time))
