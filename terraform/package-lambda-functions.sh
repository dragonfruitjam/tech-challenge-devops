# packages airport endpoint lambda function
cd ../lambda ; zip -r ../terraform/infra/airport_lambda_function.zip . ; cd ../terraform

# packages journey endpoint lambda function
python3 -m venv ../lambda/.venv                             
source ../lambda/.venv/bin/activate 
pip3 install -r ../lambda/journey-requirements.txt
mkdir ../temp
cp -rf ../lambda/.venv/lib/*/site-packages/* ../temp
cp -rf ../lambda/ ../temp
rm -rf ../lambda/.venv

rm ../temp/dockerfile
rm ../temp/handler_as_app.py
rm ../temp/handler_airport.py
rm ../temp/handler.template.py
rm ../temp/run.sh

cd ../temp ; zip -r ../terraform/infra/journey_lambda_function.zip . ; cd ..
rm -rf temp