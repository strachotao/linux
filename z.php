<?php
# zz; verze 2020-11-06; strachotao
# zkracovac url pro volani kibany;
#  jde nam o co mozna nejkratsi a zaroven funkcni url, tak aby bylo zobrazitelne jako
#  popis v nagiosu; standardni url kibany ma 600+ znaku
#
# https://zz/z.php?d=201106142015ServiceName
#  201106=rok+mesic+den
#  1420=hodin+minut
#  15=offset v minutach pro zjisteni spodni hranice intervalu
#  ServiceName=nazev esb sluzby
#
# z https://zz/z.php?d=201106142015ServiceName vytvori a presmeruje na https://kibana/s/esb/app/kibana#/discover?_g=(refreshInterval:(pause:!t,value:0),time:(from:%272020-11-06T14:05:00.000%27,mode:absolute,to:%272020-11-06T14:20:00.000%27))&_a=(columns:!(FlowName,StatusCode,LogMessage),filters:!((%27$state%27:(store:appState),meta:(alias:!n,disabled:!f,key:FlowName,negate:!f,params:(query:ServiceName,type:phrase),type:phrase,value:ServiceName),query:(match:(FlowName:(query:ServiceName,type:phrase))))),interval:auto,query:(language:kuery,query:%27%27),sort:!(%27@timestamp%27,desc))

# pri zapnutem debugu nepresmerovava, jen vypise promenne
$debug = false;

ini_set( "display_errors", 0);

date_default_timezone_set('Europe/Prague');

if(!isset($_GET['d'])) {
    exit('bez parametru...');
}

$data = $_REQUEST['d'];

$startDateY = substr($data, 0, 2);
$startDateM = substr($data, 2, 2);
$startDateD = substr($data, 4, 2);
$startTimeH = substr($data, 6, 2);
$startTimeM = substr($data, 8, 2);
$timeOffset = substr($data, 10, 2);
$serviceName = substr($data, 12, strlen($data));

$timeStamp = "20".$startDateY."-".$startDateM."-".$startDateD." ".$startTimeH.":".$startTimeM.":00";

$t0 = new DateTime($timeStamp);
$t0->modify("-$timeOffset minutes");
$t0str = $t0->format('Y-m-d\TH:i:\0\0\.\0\0\0');

$t1 = new DateTime($timeStamp);
$t1str = $t1->format('Y-m-d\TH:i:\0\0\.\0\0\0');

$url = "https://kibana/s/esb/app/kibana#/discover?_g=(refreshInterval:(pause:!t,value:0),time:(from:%27$t0str%27,mode:absolute,to:%27$t1str%27))&_a=(columns:!(FlowName,StatusCode,LogMessage),filters:!((%27\$state%27:(store:appState),meta:(alias:!n,disabled:!f,key:FlowName,negate:!f,params:(query:$serviceName,type:phrase),type:phrase,value:$serviceName),query:(match:(FlowName:(query:$serviceName,type:phrase))))),interval:auto,query:(language:kuery,query:%27%27),sort:!(%27@timestamp%27,desc))";

if ($debug) {
    echo "timeStamp = $timeStamp<br>serviceName = $serviceName<br>t0str = $t0str<br>t1str = $t1str<br>url = $url";
} else {
    echo "<html>";
    echo "<head>";
    echo "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0;URL=$url\">";
    echo "</head>";
    echo "</html>";
}

?>
