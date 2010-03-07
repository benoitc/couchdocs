This example is making use of the [[http://code.google.com/p/couchdb-python/|CouchDB Python Library]] by [[http://www.cmlenz.net/|Christopher Lenz]] and is derived from his [[http://code.cmlenz.net/diva/wiki/Divan|example blog application]].

You´ll have to create a database named `tagging_example` and a design document named `_design/posts` with the CouchDB Views below.

== CouchDB Views ==

=== all_tags ===

''map''

{{{
function(doc) {
  if (doc.type == 'post' && doc.tags) {
    doc.tags.forEach(function(tag) {
      emit(tag, 1);
    });
  }
}
}}}

''reduce''

{{{
function(keys, values) {
  return sum(values);
}
}}}

=== by_tag ===

''map''

{{{
function(doc) {
  if (doc.type == 'post' && doc.tags) {
    doc.tags.forEach(function(tag) {
      emit(tag.slug, doc);
    });
  }
}
}}}

== Create a Post model ==

Tags are entered as comma separated strings in a `TextField` called `tagstring` and will be generated from it on storing a post. As this is just a simple example, splitting the tagstring and making slugs in a sensible way is up to you.

{{{#!python
from couchdb.client import Server
from couchdb.schema import Document, Schema, DictField, ListField, TextField

server = Server('http://127.0.0.1:5984/')
db = server['tagging_example']


class Post(Document):

    type = TextField(default='post')

    title = TextField(default='')
    # ... rest of your post model: slug, body, created, etc.

    tagstring = TextField(default='')
    tags = ListField(DictField(Schema.build(
                    title = TextField(),
                    slug  = TextField()
                    )))

    def store(self, db):
        self.tags = self._make_tags()
        Document.store(self, db)

    @classmethod
    def all_tags(cls):
        return make_cloud([(row.key, row.value) for row in
                db.view('_view/posts/all_tags', group=True)])

    @classmethod
    def by_tag(cls, **options):
        return cls.view(db, '_view/posts/by_tag', **options)

    def _make_tags(self):
        taglist = set([tag.strip() for tag in self.tagstring.split(',')])
        tags = [
                dict(
                    title = tag,
                    slug  = tag.lower()
                    ) for tag in taglist
                ]
        return tags


def make_cloud(tags):
    """
    Calculation taken from Zine blogging engine.
    """
    import math
    cloud = []
    for tag in tags:
        tag[0][u'size'] = 100 + math.log(tag[1] or 1) * 20
        cloud.append(tag[0])
    return cloud
}}}

=== Add some posts with tagstrings: ===

{{{#!python
>>> p1 = Post(title=u"My first Post", tagstring=u"CouchDB, tagging, example")
>>> p1.store(db)
>>> p2 = Post(title=u"My second Post", tagstring=u"CouchDB, RESTful, HTTP, JSON, API")
>>> p2.store(db)
>>> p3 = Post(title=u"My third Post", tagstring=u"CouchDB, Erlang, HTTP")
>>> p3.store(db)
}}}

== Output ==

Looking at the `all_tags` design document in [[GettingStartedWithFuton|Futon]] you´ll see this table:

||<50% #A7AFB6> key ||<50% #A7AFB6> value ||
||<#FEFFEA> {"slug": "api", "title": "API"} ||<#FEFFEA> 1 ||
|| {"slug": "couchdb", "title": "CouchDB"} || 3 ||
||<#FEFFEA> {"slug": "erlang", "title": "Erlang"} ||<#FEFFEA> 1 ||
|| {"slug": "example", "title": "example"} || 1 ||
||<#FEFFEA> {"slug": "http", "title": "HTTP"} ||<#FEFFEA> 2 ||
|| {"slug": "json", "title": "JSON"} || 1 ||
||<#FEFFEA> {"slug": "restful", "title": "RESTful"} ||<#FEFFEA> 1 ||
|| {"slug": "tagging", "title": "tagging"} || 1 ||

The method of the Post model that calls the `all_tags` design document returns:

{{{#!python
>>> list(Post.all_tags())
[{u'size': 100.0, u'slug': u'api', u'title': u'API'},
 {u'size': 121.9722457733622, u'slug': u'couchdb', u'title': u'CouchDB'},
 {u'size': 100.0, u'slug': u'erlang', u'title': u'Erlang'},
 {u'size': 100.0, u'slug': u'example', u'title': u'example'},
 {u'size': 113.8629436111989, u'slug': u'http', u'title': u'HTTP'},
 {u'size': 100.0, u'slug': u'json', u'title': u'JSON'},
 {u'size': 100.0, u'slug': u'restful', u'title': u'RESTful'},
 {u'size': 100.0, u'slug': u'tagging', u'title': u'tagging'}]
}}}

Getting posts by a specific tag:

{{{#!python
>>> list(Post.by_tag()["example"])
[<Post u'7d2894971759039454ef29be57cc1b81'@u'1141652034' {u'tagstring': u'CouchDB, tagging, example', u'tags': [{u'slug': u'couchdb', u'title': u'CouchDB'}, {u'slug': u'example', u'title': u'example'}, {u'slug': u'tagging', u'title': u'tagging'}], u'type': u'post', u'title': u'My first Post'}>]
}}}

{{{#!python
>>> list(Post.by_tag()["couchdb"])
[<Post u'13b107ad3e14e06352b2476e015cf72f'@u'686077196' {u'tagstring': u'CouchDB, RESTful, HTTP, JSON, API', u'tags': [{u'slug': u'api', u'title': u'API'}, {u'slug': u'http', u'title': u'HTTP'}, {u'slug': u'json', u'title': u'JSON'}, {u'slug': u'couchdb', u'title': u'CouchDB'}, {u'slug': u'restful', u'title': u'RESTful'}], u'type': u'post', u'title': u'My second Post'}>,
 <Post u'7d2894971759039454ef29be57cc1b81'@u'1141652034' {u'tagstring': u'CouchDB, tagging, example', u'tags': [{u'slug': u'couchdb', u'title': u'CouchDB'}, {u'slug': u'example', u'title': u'example'}, {u'slug': u'tagging', u'title': u'tagging'}], u'type': u'post', u'title': u'My first Post'}>,
 <Post u'd71d7d8233a318745124b82f1f8a99d2'@u'667119109' {u'tagstring': u'CouchDB, Erlang, HTTP', u'tags': [{u'slug': u'http', u'title': u'HTTP'}, {u'slug': u'couchdb', u'title': u'CouchDB'}, {u'slug': u'erlang', u'title': u'Erlang'}], u'type': u'post', u'title': u'My third Post'}>]
}}}

== ToDo ==

 * Examples for retrieving Posts by multiple tags, e.g. Posts that are tagged with `CouchDB` ''and'' `HTTP`
 * Related tags, e.g. find all tags across posts that are used along with a particular tag. 
  * For `HTTP` this would be `CouchDB, Erlang, RESTful, JSON, API` as they are used in p2 and p3 along with `HTTP`.
