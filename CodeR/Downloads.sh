#!/bin/sh
# Ubuntu, or Ubuntu shell (app) on Windows (WSL 2)
#
mkdir ../Downloads
cd    ../Downloads
echo "Hans-Aloys Wischmann, Last edited: 2026-06-01"                                                | tee    Downloads.txt
echo "Heatwave mortality in France from 1990 to 2025 in high spatiotemporal resolution"             | tee -a Downloads.txt
echo "Geography   https://www.data.gouv.fr/datasets/contours-administratifs"                        | tee -a Downloads.txt
echo "Mortality   https://www.data.gouv.fr/datasets/agregation-des-fichiers-des-personnes-decedees" | tee -a Downloads.txt
echo "Population  https://www.insee.fr/fr/statistiques/1893204"                                     | tee -a Downloads.txt
echo "Rurality    https://www.insee.fr/fr/information/8571524"                                      | tee -a Downloads.txt
echo "History(A)  https://www.insee.fr/fr/information/7671867"                                      | tee -a Downloads.txt
echo "History(B)  https://opendata.koumoul.com/datasets/anciens-codes-commune"                      | tee -a Downloads.txt
echo "Exposures   https://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php"                 | tee -a Downloads.txt
echo "** E-OBS data must be acknowledged as: We acknowledge the E-OBS dataset from the EU-FP6"      | tee -a Downloads.txt
echo "project UERRA (https://www.uerra.eu) and the Copernicus Climate Change Service, and the"      | tee -a Downloads.txt
echo "data providers in the ECA&D project (https://www.ecad.eu)"                                    | tee -a Downloads.txt
echo "** Downloads started:" `date` | tee -a Downloads.txt
wget https://www.data.gouv.fr/api/1/datasets/r/c70a1c2d-dc8a-4f33-90df-ece3692b2baf                                         -O Shapes.geojson
wget https://www.data.gouv.fr/api/1/datasets/r/c75fc1d6-a6ab-496b-962d-e12b9480ed41                                         -O Deaths.csv
wget https://www.insee.fr/fr/statistiques/fichier/1893204/pop-sexe-age-quinquennal6822.zip                                  -O Census.zip
wget https://www.insee.fr/fr/statistiques/fichier/8571524/fichier_diffusion_2025.xlsx                                       -O Rurality.xlsx
wget https://www.insee.fr/fr/statistiques/fichier/7671867/table_passage_geo2003_geo2025.zip                                 -O Changes_2003_2025.zip
wget https://opendata.koumoul.com/data-fair/api/v1/datasets/anciens-codes-commune/data-files/cog-transformed.csv            -O Changes_1948_2023.csv
wget https://knmi-ecad-assets-prd.s3.amazonaws.com/ensembles/data/Grid_0.1deg_reg_ensemble/tg_ens_mean_0.1deg_reg_v33.0e.nc -O Temperature_1950_2025_v33.0e.nc
wget https://knmi-ecad-assets-prd.s3.amazonaws.com/ensembles/data/Grid_0.1deg_reg_ensemble/hu_ens_mean_0.1deg_reg_v33.0e.nc -O RelHumidity_1950_2025_v33.0e.nc
for f in Census.zip Changes_2003_2025.zip; do unzip $f; rm $f; done
mv pop-sexe-age-quinquennal6822.xlsx Population.xlsx
mv table_passage_geo2003_geo2025.xlsx Changes_2003_2025.xlsx
echo "** Downloads completed:" `date` | tee -a Downloads.txt


