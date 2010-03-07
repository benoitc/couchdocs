The simplest way is to use an the ebuild and install via portage (emerge).  This takes care of dependencies, creating the couchdb user, basically everything you need to get up and running.

{{{
echo dev-db/couchdb >> /etc/portage/package.keywords # couchdb is not in stable yet
emerge -pv couchdb # check what will be emerged, use flags, etc.
sudo emerge couchdb # actually install
}}}
