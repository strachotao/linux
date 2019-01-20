<?php
//error_reporting(E_ALL);
//ini_set('display_errors', '1');

# temp2db; version 2019-01-23; strachotao
#  ziska teplotu a srazky z api.meteo-pocasi.cz a ulozi je
#  do mysql tabulky:
#
#  CREATE TABLE IF NOT EXISTS `weather-history` (
#    `ID` int(11) NOT NULL,
#    `Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
#    `Temperature` decimal(4,1) NOT NULL,
#    `Precipitation` decimal(4,1) NOT NULL
#  ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

# pri spusteni napr z cronu, neni potreba vystup
$debug = false;

# jak maxialne stary muze byt zdrojovy soubor v sekundach, nez se stahne novy
$downfileinterval = "300";

# jak maximalne stara data v minutach zapiseme do databaze
$timedatalimit = "15";

# meteo-pocasi api ID
$mpid = "00001c2rYhB94sm47cUGdaFQJAgUB4am7jXPd4GCmSLrK8vSkQi";

# nastaveni mysql
$servername = "localhost";
$database = "db";
$username = "writer";
$password = "passwd";

# zdrojovy soubor xml dat, key key=nazev_souboru a value=url, nemenit
$files = array(
    "api.xml" => "http://api.meteo-pocasi.cz/api.xml?action=get-meteo-data&client=xml&id=$mpid",  
);

foreach($files as $file => $url) {
  if (is_file($file) && time() - filemtime($file) >= $downfileinterval || !is_file($file) || filesize($file) == 0) {      
      $fp = fopen($file, 'w'); 
      $ch = curl_init($url);
      curl_setopt($ch, CURLOPT_FILE, $fp); 
      $data = curl_exec($ch);
      curl_close($ch);
      fclose($fp);
  }
}

$xml_api_reply = simplexml_load_file("api.xml") 
or die("api.xml nelze precist jako XML<br>");

$lastcomm = $xml_api_reply->last_communication;
$lastcommunication = strtotime($lastcomm);
$meteostatus = $xml_api_reply->status;

foreach ($xml_api_reply->input->sensor as $sensor){
    if ($sensor->type == "temperature") {
        $temperature = $sensor->value;
    }
    if ($sensor->type == "precipitation") {
        $precipitation = $sensor->value;
    }
}

if ($debug) {
    echo "Posledni komunikace se stanici: $lastcomm<br>";
    echo "Status stanice: $meteostatus<br>";
    echo "Teplota: $temperature<br>";
    echo "Srazky: $precipitation<br>";
}

if (time() - $lastcommunication < $timedatalimit * 60) {
    $conn = mysqli_connect($servername, $username, $password, $database);
    if (!$conn) {
        die("Pripojeni do db selhalo: " . mysqli_connect_error());
    }
    if ($debug) {echo "Pripojeni do databaze je v poradku<br>";}
    $sql = "INSERT INTO `weather-history` (temperature, precipitation) VALUES ('$temperature', '$precipitation')";
    if (mysqli_query($conn, $sql)) {
        if ($debug) {echo "Data byla zapsana do databaze<br>";}
    } else {
        if ($debug) {echo "Chyba: " . $sql . "<br>" . mysqli_error($conn);}
    }
    mysqli_close($conn);
} else {
    if ($debug) {echo "Neni co delat, meteo data jsou starsi jak  $timedatalimit minut!<br>";}
}

?>
