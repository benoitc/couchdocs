To setup an instance-wide Admin account, edit your local.ini file addding a section like:
{{{
[admins]
jchris = mytopsecretpassword
}}}
When you launch CouchDB, it will convert this into something like this and save it back to the file:
{{{
[admins]
jchris = -hashed-207b1b4f8434dc60429672c0c2ba3aae61568d6c,96406178a0718239acb72cb4e8f2e66e
}}}
If you wish to remove all handling of authentication, make sure to add to your local.ini
{{{
[httpd]
authentication_handlers = {couch_httpd_auth, null_authentication_handler}
}}}
