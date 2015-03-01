cabal build && dist/build/site/site build
chmod -R a+rX _site
rsync -r _site/* amosr@cse.unsw.edu.au:public_html/ -v
