chmod a+rX -R _site
rsync -r _site/* amosr@cse.unsw.edu.au:public_html/ -v
