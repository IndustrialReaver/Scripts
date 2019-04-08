import requests

url = "http://www.forbes.com/forbesapi/thought/uri.json?enrich=true&query=1&relatedlimit=5"
response = requests.get(url)
data = response.json()

print("\"",data['thought']['quote'].strip(),"\"\n -- ",data['thought']['thoughtAuthor']['name'].strip())