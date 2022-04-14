## this is a pain in the ass

# get OSD by MO or soil order... either way we miss some

# figure out which series are missing from MO, but in the ORDER query:
# ls oseds > osd_by_mo.list # these are via MO-query
# ls oseds-backup > osd_by_tax.list  # these are via ORDER query
# missing=`diff -y osd_by_mo.list osd_by_tax.list | grep ">" | awk  '{print $2}'`

# copy over
# for x in $missing; do cp oseds-backup/$x oseds/$x; done

# process horizonation and color data
rm output.txt
for x in oseds/*.txt ; do python parse_osd.py $x ; done

# run integration.sql
psql -U postgres ssurgo_combined < integration.sql


# fix problems, adjust parser, ... ?
