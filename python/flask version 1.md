*Resources*
https://docs.graphene-python.org/en/latest/

# Implementing GraphQL in Flask in Windows environment in local machine
Here I explain how to implement GraphQL server in local machine in windows environment. Following are the steps:

1. For database connectivity I used config.json file as below:
```{
    "trackTest": {
        "user":"webadmin",
        "password":"*****",
        "host":"*****",
        "port":***,
        "database":"trackTest"
    }
}
```

2. Created a file adam1-gql.py. The code in adam1-gql.py is as follows:
***adam1-gql.py***
```
from GqlHelper import GHelper
app = GHelper.app
    
if __name__ == '__main__':
    app.run()
```

3. Creat a folder GqlHelper and add a file GHelper.py in it. This file has actual code in it.
The folder GqlHelper works as package in Python. I put a `__init__.py` blank file in this folder, which makes it to behave like apackage. The code in GHelper.py is as follows.

***GHelper.py***
```
from flask import Flask
from graphene import ObjectType, String, Int, Float, Field, Schema, List
from flask_graphql import GraphQLView
import requests
import simplejson as json
import psycopg2
from psycopg2.extras import RealDictCursor
app = Flask(__name__)
url = 'http://chisel.cloudjiffy.net/contacts/short'
with open('config.json') as json_file:
    cfg = json.load(json_file)

sql = '''
set search_path to test; 
with RECURSIVE cte 
    as ( select m."id", m."accCode", m."parentId", t."amount" from "AccTran" t 
        join "AccM" m on t."accCode" = m."accCode" 
    union select a.id,a."accCode", a."parentId"
        , ( cte."amount") as "amount" from "AccM" a join cte on cte."parentId" = a.id ) 
select id, "accCode", "parentId", sum(amount) as amount
    from cte 
        group by id, "accCode", "parentId" order by cte.id
'''

try:
    connection = psycopg2.connect(user=cfg['trackTest']['user'], password=cfg['trackTest']['password'], host=cfg['trackTest']['host'], port=cfg['trackTest']['port'], database=cfg['trackTest']['database'])
    cursor = connection.cursor(cursor_factory=RealDictCursor)
except (Exception, psycopg2.Error) as error :
    print ("Error while connecting to PostgreSQL", error) 

class PersonType(ObjectType):
    firstName = String()
    lastName = String()
    age = Int()

class AccountType(ObjectType):
    id = Int()
    accCode = String()
    parentId = Int()
    amount = Float()

class Query(ObjectType):
    hello = String()
    person = Field(PersonType)
    people = List(PersonType)
    contacts = String()
    accounts = List(AccountType)
    def resolve_hello(self, args):
        return 'Hello World'
    def resolve_person(self,args):
        return {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56}
    def resolve_people(self, args):
        return [
            {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56},
            {'firstName':'Sushant1', 'lastName':'Agrawal1', 'age':57}
        ]    
    def resolve_contacts(self,args):
        r = requests.get(url)
        return r.text    
    def resolve_accounts(self, args):
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        cursor.execute(sql)
        rows = cursor.fetchall()
        j = json.dumps(rows, indent=2)
        list = json.loads(j)
        cursor.close()
        return(list)

class Mutation(ObjectType):
    addHello = String()

    def resolve_addHello(self, args):
        return 'Hello world in mutation'

schema = Schema(query=Query, mutation = Mutation)

@app.route('/')
def hello_world():
    r = requests.get(url)
    return (r.text)

app.add_url_rule('/graphql', view_func=GraphQLView.as_view(
    'graphql',
    schema=schema,
    graphiql=True
))
```

4. Change folder to `flask`. Create python virtual environment using following commands in windows operatig system, using command prompt:
```
pip install virtualenv
virtualenv env
env\scripts\activate
pip install requests graphene flask_graphql simplejson psycopg2
```
This completes the coding and environment setup.

Total folder structure is as follows:
```
flask
	env
	adam1-gql.py
	GqlHelper
		`__init__`.py
		GHelper.py
```

You run the program as
```
python adam1-gql.py
```

### Explaination ###
Code in adam1-gql.py simply calls GqlHelper.GHelper and imports app object
In GHelper file Query class is created having many fields such as hello, person, people, contacts, accounts. These fields make use of other classes which are already defined earlier to Query class. Now for every field you have to create resolver in the format resolve_fieldname. Notice how you can mix different types of data such as String, object, data from API, data from database in the fields and thereby resolvers. You run the Flask server by giving command `python adam1-gql.py`. Now you can browse as http://localhost:5000/graphql. This will display GraphIql interface. In that interface you can give commands like:
`
{
	hello
}
{
	accounts
}
{
	contacts
}
`

####Key points to remember for GraphQL with Graphene in Python:####
1. Create classes for all objects
2. Create Query class and put all your queries in Query class as properties. Also write resolver functions for all properties in Query class
```class Query(ObjectType):
    hello = String()
    person = Field(PersonType)
    people = List(PersonType)
    contacts = String()
    accounts = List(AccountType)
    personById =  Field(PersonType, id=Int(required=True)) #List(AccountType, id=Int(required=True))

    def resolve_hello(self, args):
        return 'Hello World'

    def resolve_person(self,args):
        return {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56}

    def resolve_people(self, args):
        return [
            {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56},
            {'firstName':'Sushant1', 'lastName':'Agrawal1', 'age':57}
        ]
    
    def resolve_contacts(self,args):
        r = requests.get(url)
        return r.text
    
    def resolve_accounts(self, args):
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        cursor.execute(sql)
        rows = cursor.fetchall()
        j = json.dumps(rows, indent=2)
        list = json.loads(j)
        cursor.close()
        return(list)
    
    def resolve_personById(self, args, id):
        return {'firstName':'Ujjal', 'lastName':'Saha', 'age':50}
```
3. Create Mutation class and put all your mutations in Mutation class as properties. Also write resolver functions for all properties in Mutation class. It is same as Query explained above.
```class Mutation(ObjectType):
    addHello = String()

    def resolve_addHello(self, args):
        return 'Hello world in mutation'
```
4. Remember to set the schema as follows:
```
schema = Schema(query=Query, mutation = Mutation)
```


# Implementing GraphQL in Flask in Cloudjiffy
I was looking for a good Python web server & application server combination in cloud. I came across Cloudjiffy / Jelastic PAAS cloud environment. They offer front facing Apache web server. At the back if you want to code in Python, you have a choice between Django and Flask. Django is more popular. I found too much boiler plate code in Django. In comparison I found Flask to be very light weight. I was looking for implementation of GraphQL API in Python and I wanted good flexibility for Python coding. I do not like ORM since they limit your coding. In Flask there is no ORM. For database handling you need to write your own code. I liked that. I selected Flask application server front faced in default by Apache web server.

Steps to create GraphQL API using Flask in Cloudjiffy / Jelastic
1. Create environment:
	Create a new Python environment using latest version of Apache and Python. After the environment is created you will find in folder /var/www/webroot/ROOT a wsgi.py file. The wsgi.py file by default makes use of pyinfo.py file to display default screen. If you browse you will see a default screen, which establishes that things are all right.
2. Create environment using Virtual environment
	Create a virtual environment by name virtenv. You will install all python libraries in this virtenv. Cloudjiffy automatically installs the virtualenv package for you, you need to just make use of it. I created the environment as follows:
	a) In the `ROOT` folder I created my application folder as `FlaskApp`. All my custom code and virtual environment will reside inside the `FlaskApp`. This folder will work as Python package.
	b) Use the Cloudjiffy command prompt through `web SSH`. Give command `cd /var/www/webroot/ROOT/FlaskApp` to go to the folder FlaskApp
	c) Create virtenv and install softwares in virtenv for making them available to Python code
	```
	virtualenv virtenv
	source virtenv/bin/activate
	pip install requests graphene flask_graphql simplejson psycopg2
	```
	d) In FlaskApp folder create an empty file `__init__`.py. This file signifies that current folder will be used as Python package.

3. Alter wsgi.py file:
	Put following code into wsgi.py file
```
import sys, os, logging
logger=logging.getLogger()
    
path = '/var/www/webroot/ROOT'
if path not in sys.path:
    sys.path.append(path)
virtenv = os.path.expanduser('~') + '/ROOT/FlaskApp/virtenv/'
virtualenv = os.path.join(virtenv, 'bin/activate_this.py')
try:
    exec(compile(open(virtualenv, "rb").read(), virtualenv, 'exec'), dict(__file__=virtualenv))
    from FlaskApp import GraphQLApi
    application = GraphQLApi.app
except Exception as e:
    logger.error(e)
```

By default the code uses the folder '/var/www/webroot'. You need to change the system path to '/var/www/webroot/ROOT'. The above code starts the 'virtenv' virtual environment through script. The purpose of wsgi.py file is to create an application object. We create the application object from GraphQLApi.app. The FlaskApp folder is used as python package. All the actual code for GraphQL api is in FlaskApp folder.

4. Create config.json
	For PostgreSQL connection create a config.json file in FlaskApp folder. The content of config.json is:
	```
	{
    "trackTest": {
        "user":"webadmin",
        "password":"*****",
        "host":"192.168.1.113",
        "port":5432,
        "database":"trackTesting"
    }
	}
	```
	Since the connection to PostgreSQL is to be made from Cloudjiffy server in local area network, hence you need to give LAN IP address and default port 5432. This is not the case when database is to be connected from browser.

5. Create the GraphQLApi.py in the FlaskApp folder and put following code inside it:
```
import logging, os
from flask import Flask
from graphene import ObjectType, String, Int, Float, Field, Schema, List
from flask_graphql import GraphQLView
import requests
import simplejson as json
import psycopg2
from psycopg2.extras import RealDictCursor
logger=logging.getLogger()

app = Flask(__name__)
url = 'http://chisel.cloudjiffy.net/contacts/short'
logger.warning(os.getcwd())
cfgFilePath = os.path.expanduser('~') + '/ROOT/FlaskApp/config.json'
logger.warning(cfgFilePath)
with open(cfgFilePath) as json_file:
    cfg = json.load(json_file)
    logger.warning(cfg)

sql = '''
set search_path to test; 
with RECURSIVE cte 
    as ( select m."id", m."accCode", m."parentId", t."amount" from "AccTran" t 
        join "AccM" m on t."accCode" = m."accCode" 
    union select a.id,a."accCode", a."parentId"
        , ( cte."amount") as "amount" from "AccM" a join cte on cte."parentId" = a.id ) 
select id, "accCode", "parentId", sum(amount) as amount
    from cte 
        group by id, "accCode", "parentId" order by cte.id
'''

try:
    connection = psycopg2.connect(user=cfg['trackTest']['user'], password=cfg['trackTest']['password'], host=cfg['trackTest']['host'], port=cfg['trackTest']['port'], database=cfg['trackTest']['database'])
    cursor = connection.cursor(cursor_factory=RealDictCursor)
except (Exception, psycopg2.Error) as error :
    logger.warning (error)
    
class PersonType(ObjectType):
    firstName = String()
    lastName = String()
    age = Int()

class AccountType(ObjectType):
    id = Int()
    accCode = String()
    parentId = Int()
    amount = Float()

class Query(ObjectType):
    hello = String()
    person = Field(PersonType)
    people = List(PersonType)
    contacts = String()
    accounts = List(AccountType)

    def resolve_hello(self, args):
        return 'Hello World'

    def resolve_person(self,args):
        return {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56}

    def resolve_people(self, args):
        return [
            {'firstName':'Sushant', 'lastName':'Agrawal', 'age':56},
            {'firstName':'Sushant1', 'lastName':'Agrawal1', 'age':57}
        ]
    
    def resolve_contacts(self,args):
        r = requests.get(url)
        return r.text
    
    def resolve_accounts(self, args):
        cursor = connection.cursor(cursor_factory=RealDictCursor)
        cursor.execute(sql)
        rows = cursor.fetchall()
        j = json.dumps(rows, indent=2)
        list = json.loads(j)
        cursor.close()
        return(list)

schema = Schema(query=Query)

@app.route("/")
def hello():
    return "Hello, I love Digital Ocean!"
@app.route("/test")
def test():
    r = requests.get(url)
    return r.text

app.add_url_rule('/graphql', view_func=GraphQLView.as_view(
    'graphql',
    schema=schema,
    graphiql=True
))
```

The code is more or less the same as that in local machine. There is some difference, see the code for making use of config.json file. You need to change the path for reading the file from current folder. By default the path is set to \webroot. So you use the code `cfgFilePath = os.path.expanduser('~') + '/ROOT/FlaskApp/config.json'` to change the path.

This completes the code. If everything is fine after restarting the node you can browse at /graphql and make use of GraphQL web interface to check the GraphQL queries.
One important nore: The logger writes to httpd/error_log file. The logger.warning('logging information') is fine enough to log your data in error_log file.

Total folder structure is as follows:
```
/var/www/webroot/ROOT
	wsgi.py
	FlaskApp
		virtenv
		config.json
		GraphQLApi.py
		__init__.py
```

Happy coding.