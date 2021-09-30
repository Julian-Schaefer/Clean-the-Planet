heroku git:remote -a clean-the-planet
cd ..
git subtree push --prefix server/ heroku master
cd server