<?php

function writeCommand ($serialCommand) {
    $handle = fopen('file.txt', "w");
    fwrite($handle, $serialCommand);
    fclose($handle);
}

function writeCommand_Name ($serialCommand, $name) {
    $stringToWrite = $serialCommand;
    $stringToWrite .= ", " . $name;
    $handle = fopen('file.txt', "w");
    fwrite($handle, $stringToWrite);
    fclose($handle);
}

function writeCommand_Name_Audio ($serialCommand, $name, $audiocommand) {
    $stringToWrite = $serialCommand;
    $stringToWrite .= ", " . $name;
    $stringToWrite .= ", " . $audiocommand;
    $handle = fopen('file.txt', "w");
    fwrite($handle, $stringToWrite);
    fclose($handle);
}

?>