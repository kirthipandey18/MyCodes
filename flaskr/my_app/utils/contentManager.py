from pathlib import Path
import json

p = Path('.') / 'my_app' / 'posts'
results = [] 

def generateContent(p=p):
    r = []
    dfs = p.iterdir()
    for i in dfs:
        if i.is_dir():
            dir_dict = {}
            dir_dict['text'] = i.name
            res = generateContent(i)
            if res is not []:
                dir_dict['nodes'] = res
            r.append(dir_dict)
        else: # file
            file_dict = {}
            file_dict['text'] = i.name
            file_dict['href'] = str(i)[str(i).find('posts')+len('posts/'):].replace('.mk','').replace("/","-")
            r.append(file_dict)
    return r

def getContent():
    return json.dumps(generateContent())

def getPost(url):
    try:
        post = open(str(p)+'/'+url.replace("-","/")+'.mk')
    except:
        return str(p)+url.replace("-","/")+'.mk'
    post = post.read()
    import markdown
    return markdown.markdown(post)

if __name__ == "__main__":
    print(getContent())
