#!/usr/bin/perl

#use to get options
use Getopt::Long;

#specify your default options here

$device_default = "/dev/ide/host0/bus1/target0/lun0/cd"; #my cd writer's id
$mode_default = "tao"; #default writing mode
$driveropts_default = "burnfree"; #default driver options
$type_dafault = "data"; #default cd type


#end of default settings

#specify the options
GetOptions( "help" => \$help,
	"master" => \$master,
	"mode=s" => \$mode,
	"speed=i" => \$speed,
	"type=s" => \$type,
	"source=s" => \$source,
	"multi" => \$multi,
	"tracksize=s" => \$tracksize,
	"burn" => \$burn,
	"device=s" => \$device);

if ($help){
	print "Welcome to burnig world with Burn It Up\n";
	print "\n";
	print "You should specify these options:\n";
	print "--help :shows this help\n";
	print "--device :specify the cd-recorder eg /dev/hdc\n";
	print "--mode :this can be tao(track at once, sao(disk\n";
	print " at once) or raw96r\n";
	print " Note: choose sao for digital mastering\n";
	print "--master :use digital mastering\n";
	print " Note: 700mb cd becomes 595mb\n";
	print "--speed :set writing speed 1-50\n";
	print "--type :this is either data or audio\n";
	print "--source :the path of the source dir\n";
	print "--multi :choose if you want to create a multisession disk\n";
	print "--tracksize :needed for sao(disk at once) mode.\n";
	print "--burn :this will really burn the cd otherwise, it writes\n";
	print " in simulation(dummy) mode.\n";
	exit;
}

if($device eq ""){
	$device = $device_default;
}

if ($source eq ""){
	print "Burn It Up: No sourec dir specied. Please enter the source dir path\n";
	exit;
}

if ($speed == 0){
	print "Burn It Up: No writing speed specified. Please specify the wrinting speed 1-48x\n";
	exit;
}

if ($mode eq ""){
	$mode = $mode_default;
	print "Burn It Up: No writing mode specified. Using primarily tao mode.\n";
}

if ($master){
	$driveropts = "burnfree,audiomaster";
	$mode = "sao";
	print "Burn It Up: Digital mastering enabled. Switching to sao mode.\n";
} else{
	$driveropts = $driveropts_default;
}

if ($mode eq "sao"){
	print "Burn it up: You must specify the track size using the --tracksize paramater.\n";
	print " You can retrive the tracksize value from below:\n";
	print " write as this --tracksize XXXXs\n";
	$status = system("mkisofs -R -J -q -print-size $source");
	if($tracksize){
		$tsize = "tsize=$tracksize";
	}
	else{
		$tsize = "";
		#exit;
	}
}

if ($type eq ""){
	print "Burn It Up: No cd type specified. Writing data cd.\n";
	$type = $type_dafault;
}

if ($multi){
	$opt1 = "-multi";
}
else{
	$opt1 = "";
}

if ($burn){
	$dummy = "";
}
else{
	$dummy = "-dummy";
}

$status = system("rm -f temp.iso && mkisofs -r -R -J -o temp.iso $source && cdrecord -v -$mode $dummy $opt1 speed=$speed driveropts=$driveropts dev=$device -$type $tsize temp.iso && rm -f temp.iso");

die "Writing CD failed. cdrecord exited with Status Code $?" unless $status == 0;
