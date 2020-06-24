#!/bin/bash
WORKING_DIR="TemplateDeploy"
URL="backend"
SECURE="http"
while getopts ":u:d:e:h" opt; do
      case $opt in
        d ) WORKING_DIR="$OPTARG";;
        u ) URL="$OPTARG";;
        s ) SECURE="$OPTARG";;
        h )
            echo "Usage:"
            echo "    deploy.sh -h               Display this help message."
            echo "    deploy.sh -d               Name of the destination Directory"
            echo "    deploy.sh -u               Name of the url of the host"
            echo "    deploy.sh -s               http or https"
            exit 0
            ;;
        \?) echo "Invalid option: -"$OPTARG"" >&2
            exit 1;;
        : ) echo "Option -"$OPTARG" requires an argument." >&2
            exit 1;;
      esac
    done

echo "Your working directory is "$WORKING_DIR""
echo "Your url is "$SECURE://$URL""

if [ -d "$WORKING_DIR" ]; then rm -Rf $WORKING_DIR; fi
if [ -d "$WORKING_DIR.zip" ]; then rm -Rf $WORKING_DIR.zip; fi

# Change the url
echo "export const ROOT_URL = '$SECURE://$URL';" > ./frontend/src/app/url.ts

# Compile angular
cd ./frontend
npm run build
cd ..

# Make directories and copy
mkdir $WORKING_DIR
mkdir $WORKING_DIR/frontend
cp -r ./frontend/dist ./$WORKING_DIR/frontend
cp -r ./backend ./$WORKING_DIR
cp -r ./nginx ./$WORKING_DIR
cp -r ./.env ./$WORKING_DIR
cp -r ./docker-compose.yml ./$WORKING_DIR

# Change nginx configuration
#cp -r ./init-letsencrypt.sh ./$WORKING_DIR
cd ./$WORKING_DIR/nginx
# sed -i 's/example.org/"$URL"/g' nginx.conf Linux version
sed -i '' 's/example.org/'"${URL}"'/g' nginx.conf
cd ../..
# sed -i 's/example.org/"$URL"/g' init-letsencrypt.sh Linux version
#sed -i '' 's/example.org/'"${URL}"'/g' init-letsencrypt.sh
#cd ..

# Zip deploy
zip -r $WORKING_DIR.zip $WORKING_DIR
rm -Rf $WORKING_DIR




