awk -F "\"" '{if (length($4)>0) print "sed -i \047s/"$4"/"$2"/\047 nightly-validation-LSSTCam-*yaml"}' step-translation.json | grep -v "No final sources"
