#!/bin/sh

WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe
FIG_REPO=/home/lzhenn/array/lzhenn/wrf-sdpwfe-fig

LID=`date -d '1 days ago' +%Y%m%d`

TS_DIR=$FIG_REPO/timeseries/$LID
MAP_DIR=$FIG_REPO/maps/$LID

mkdir $TS_DIR
mkdir $MAP_DIR


#--------------------------------------------------------------
#       First Phase: Track in domains 
#--------------------------------------------------------------

echo "Phase I: plot..."
cd $WORKDIR/ncl
ncl -nQ 180124-plot-T2m-RH-timeseries.ncl & 
ncl -nQ 180212-plot-profile-timeseries.ncl &
ncl -nQ  180212-plot-cloud-profile-timeseries.ncl &
ncl -nQ  180212-plot-surface-wind-timeseries.ncl &
ncl -nQ  180205-plot-snow-cover.ncl &
ncl -nQ  180205-plot-precip.ncl &
ncl -nQ  180207-plot-T2m.ncl &
ncl -nQ  180207-plot-RH2m.ncl &
ncl -nQ  180207-plot-UV10m.ncl &
wait

cd $WORKDIR/fig

echo "Phase I: convert..."

# Cut borders
convert -trim +repage -bordercolor white -background white -flatten T2m-home.png  T2m-home.png
convert -trim +repage -bordercolor white -background white -flatten Wind10m-home.png Wind10m-home.png
convert -trim +repage -bordercolor white -background white -flatten profile-home.png profile-home.png
convert -trim +repage -bordercolor white -background white -flatten cloud-profile-home.png cloud-profile-home.png
for((I=0;I<=24;I++))
do
    TF=$(expr $I \* 3)
    TFSTMP=`printf "%.3d" $TF`
    convert -trim +repage -bordercolor white -background white -flatten snow-cover_${TFSTMP}H.png snow-cover_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten precip_${TFSTMP}H.png precip_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten T2m_${TFSTMP}H.png T2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten RH2m_${TFSTMP}H.png RH2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten Wind10m_${TFSTMP}H.png Wind10m_${TFSTMP}H.png
done

# convert gif
convert -delay 100 snow-cover_* snow-cover.gif &
convert -delay 100 precip_* precip.gif &
convert -delay 100 T2m_* T2m.gif &
convert -delay 100 RH2m_* RH2m.gif &
convert -delay 100 Wind10m_* Wind10m.gif &

#compress gif
convert snow-cover.gif -fuzz 5% -layers Optimize snow-cover.gif
convert precip.gif -fuzz 5% -layers Optimize precip.gif
convert T2m.gif -fuzz 5% -layers Optimize T2m.gif
convert RH2m.gif -fuzz 5% -layers Optimize RH2m.gif
convert Wind10m.gif -fuzz 5% -layers Optimize Wind10m.gif
wait

# Move realtime figures to repo
echo "Phase I: organize files..."
cp T2m-home.png $TS_DIR 
cp Wind10m-home.png $TS_DIR 
mv snow-cover_* $MAP_DIR
mv precip_* $MAP_DIR
mv T2m_* $MAP_DIR
mv RH2m_* $MAP_DIR
mv Wind10m_* $MAP_DIR

cd $WORKDIR
echo "Phase I: git push..."
sh gitfresh.sh 
#--------------------------------------------------------------
#                 Second Phase: D01 D02 Maps
#--------------------------------------------------------------

echo "Phase II: plot..."
cd $WORKDIR/ncl
ncl -nQ  180210-plot-d02-precip.ncl &
ncl -nQ  180210-plot-d02-snow-cover.ncl &
ncl -nQ  180210-plot-d02-T2m.ncl &
ncl -nQ  180210-plot-d02-RH2m.ncl &
ncl -nQ  180210-plot-d02-UV10m.ncl &
wait

ncl -nQ  180210-plot-d01-precip.ncl &
ncl -nQ  180210-plot-d01-snow-cover.ncl &
ncl -nQ  180210-plot-d01-T2m.ncl &
ncl -nQ  180210-plot-d01-RH2m.ncl &
ncl -nQ  180210-plot-d01-UV10m.ncl &
wait


cd $WORKDIR/fig


echo "Phase II: convert..."

for((I=0;I<=24;I++))
do
    TF=$(expr $I \* 3)
    TFSTMP=`printf "%.3d" $TF`

    convert -trim +repage -bordercolor white -background white -flatten d01_snow-cover_${TFSTMP}H.png d01_snow-cover_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d01_precip_${TFSTMP}H.png d01_precip_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d01_T2m_${TFSTMP}H.png d01_T2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d01_RH2m_${TFSTMP}H.png d01_RH2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d01_Wind10m_${TFSTMP}H.png d01_Wind10m_${TFSTMP}H.png

    convert -trim +repage -bordercolor white -background white -flatten d02_snow-cover_${TFSTMP}H.png d02_snow-cover_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d02_precip_${TFSTMP}H.png d02_precip_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d02_T2m_${TFSTMP}H.png d02_T2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d02_RH2m_${TFSTMP}H.png d02_RH2m_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten d02_Wind10m_${TFSTMP}H.png d02_Wind10m_${TFSTMP}H.png
done

# convert gif
convert -delay 100 d02_snow-cover_* d02_snow-cover.gif &
convert -delay 100 d02_precip_* d02_precip.gif &
convert -delay 100 d02_T2m_* d02_T2m.gif &
convert -delay 100 d02_RH2m_* d02_RH2m.gif &
convert -delay 100 d02_Wind10m_* d02_Wind10m.gif &

convert -delay 100 d01_snow-cover_* d01_snow-cover.gif &
convert -delay 100 d01_precip_* d01_precip.gif &
convert -delay 100 d01_T2m_* d01_T2m.gif &
convert -delay 100 d01_RH2m_* d01_RH2m.gif &
convert -delay 100 d01_Wind10m_* d01_Wind10m.gif &
wait


echo "Phase II: organize files..."
# Move realtime figures to repo
mv d02_snow-cover_* $MAP_DIR
mv d02_precip_* $MAP_DIR
mv d02_T2m_* $MAP_DIR
mv d02_RH2m_* $MAP_DIR
mv d02_Wind10m_* $MAP_DIR

mv d01_snow-cover_* $MAP_DIR
mv d01_precip_* $MAP_DIR
mv d01_T2m_* $MAP_DIR
mv d01_RH2m_* $MAP_DIR
mv d01_Wind10m_* $MAP_DIR


echo "Phase II: git push..."
cd $WORKDIR
sh gitfresh.sh 


