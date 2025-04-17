from pytube import YouTube

url = input()
urlConvert = YouTube(url)
titulo = urlConvert.title
