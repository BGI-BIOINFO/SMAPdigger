#!/bin/env perl
use strict;
#use warnings;
use Data::Dumper;
use File::Basename;
use Getopt::Long;
use PerlIO::gzip;

use FindBin '$Bin';
use File::Basename qw(basename dirname);
use lib qw($Bin/lib/compress);

my ($mode , $Help);
GetOptions(
        "mode:s"=>\$mode,
        "help"=>\$Help
);

&usage() if(@ARGV<2 || $Help || ! $mode);

my $in=shift;
my $out=shift;

if($mode=~/se/){
	&seID(\$in,\$out);
}
if($mode=~/pe/){
	&peID(\$in,\$out);
}
if($mode=~/to/){
	&totalID(\$in,\$out);
}

#FCC01P5ACXX:8:1101:10000:165404#ACTTGAAT/2:rep1:+:len90:C       chrX    109590074       CAACCTCCAACTAAAACTATTAAACCACTTTCTTCGTAACGACGACGCTAAAAAAACCAAACATAATAAACGCGAAAACCGAGATCGGAA      |##||||||#||##|#||#||#|||||||||||||m||#|m#|m||m||##|#||#|||#||||##|#|||m|m####||m#m             CGGCCTCCAGCTGGAGCTGTTGAACCACTTTCTTCGTAGCGGCGACGCTGGAGAAGCCAGACATGGTGAACGCGGGGGCCGGGCCGATTC      abbeeeeegfgegffhfdffhhiigfcggf`gfgffhiihfhfffgfdgbadgdeccacc`aabbcbbbc_VT]][T]^W[T]aaca_ac


sub seID
{

	my $input=shift;
	my $output=shift;
	if($$input=~/.gz$/){
		open IN,"gunzip -c $$input|" ||die "no inputse\n";
	}else{	
		open IN,$$input ||die "no se_input"		
	}
	open OUT,">$$output" || die "can't creat output\n";

	my $lastline=<IN>;
	chomp $lastline;
	my @array;
	push (@array,$lastline);
	while(<IN>) {
		chomp;
		my $line=$_;
		my @b=split /\t/,$line;
		my @a=split /\t/,$lastline;
		my $readname;
		my ($readname1,$readname2,$rep1,$rep2,$strand1,$strand2,$len1,$len2,$word1,$word2);
		if($a[0]=~/^(\S+)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
			$readname=$1;
			$readname1="$1$2";
			$rep1=$3;
			$strand1=$4;
			$len1=$5;
			$word1=$6;
		}	
		if($b[0]=~/^(\S+)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
                        $readname2=$1;
                        $rep2=$2;
                        $strand2=$3;
                        $len2=$4;
                        $word2=$5;
                }
		
		if($readname1 eq $readname2){	
			push @array,$line;

		}else{
			#print OUT $array[0]."\n";
			if(@array==1){
			  my $unmaplenth=$a[4]=~tr/ / /;
			  my $maplenth=$len1-$unmaplenth;
			  my $end=$a[2]+$len1-1;
			  if($strand1 eq '+'){	
				print OUT "$readname\t$a[1]$word1\t$a[2]\t0\t$maplenth\t$array[0]\n";
			  }elsif($strand1 eq '-'){
			  	print OUT "$readname\t$a[1]$word1\t0\t$end\t$maplenth\t$array[0]\n";
			  }	
			}else{
				&getseline(\@array,\*OUT);
			}
			@array=();
			push(@array, $line);
		}
			
		$lastline=$line;	
		
	}
	close IN;
	if(@array>0){
		
		#print OUT $array[0]."\n";
	}
	close OUT;
}


sub peID
{
	my $input=shift;
	my $output=shift;
	if($$input=~/.gz$/){
		open IN,"gunzip -c $$input|" or die "no inputpe"
	}else{
		open IN,$$input or die "no inputpe\n";
	}
	open OUT,">$$output" or die "can't creat output\n";
	while(<IN>){
		my $line1=$_;
		my $line2=<IN>;
		my $line3;
		my $line4;
		chomp ($line1,$line2);
#FCC01P5ACXX:8:1101:10000:102007#ACTTGAAT/1:rep2:-:len90:C      chr21   33429248        CGCCTATAATCCCAACATTTTAAAAAACCGAAACAAAAAAATCACGAAATCACGAAATTAAAACCATCCTAACTAACACGATAAAACCCG      |m|||#||||||||#||||||###|##||m|##|#|#|##|||||m|##||| m|#|||#|#||||||||##||||||| #|#||||||       cgcctgtaatcccagcattttgggaggccgaggcgagaggatcacgaggtcaggagattgagaccatcctggctaacacagtgaaacccc      ccccdcccbccccddcdcccccccccaegggiiiihiiiiighgiiihgfheiiiihiiihhgiihfiihhhihgehggggfeeeeebba
		
		
		my @line1=split /\t/,$line1;
		my @line2=split /\t/,$line2;	
		my @line3;
		my @line4;
		
		
		my ($name1, $name2,$name3,$name4,$len1,$len2,$len3,$len4,$rep1,$rep2,$rep3,$rep4,$word1,$word2,$word3,$word4,$str1,$str2,$str3,$str4,$read1,$read2,$read3,$read4);
		
		if($line1[0]=~/^(\S+\/)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
			$name1=$1;$read1=$2;$rep1=$3;$str1=$4;$len1=$5;$word1=$6;
		}
		if($line2[0]=~/^(\S+\/)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){	
			$name2=$1;$read2=$2;$rep2=$3;$str2=$4;$len2=$5;$word2=$6;
		}
		my $pname1="$name1$read1";
		my $pname2="$name2$read2";
		my $pname3;
		my $pname4;
		my $unmap1=$line1[4]=~tr/ / /;
		my $unmap2=$line2[4]=~tr/ / /;
		my $unmap3;
		my $unmap4;

		my $map1=$len1-$unmap1;
		my $map2=$len2-$unmap2;
		my $map3;
		my $map4;

		#my $nomapI=$unmap1+$unmap3;
		#my $nomapII=$unmap2+$unmap4;
		#my $repI=$rep1+$rep3;
		#my $repII=$rep2+$rep4;


		if($pname1 ne $pname2){
			if($name1 eq $name2){
				&getpeline(\@line1,\@line2,$word1,$word2,$str1,$str2,$name1,$name2,\*OUT);
			}else{
				print STDERR "$pname1 and $pname2 are not pe\n";
			}
		}else{
			$line3=<IN>;
			$line4=<IN>;
			chomp($line3,$line4);
			@line3=split (/\t/,$line3);
			@line4=split (/\t/,$line4);
			if($line3[0]=~/^(\S+\/)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
             	        	$name3=$1;$read3=$2;$rep3=$3;$str3=$4;$len3=$5;$word3=$6;
               		 }
                	if($line4[0]=~/^(\S+\/)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
                 		$name4=$1;$read4=$2;$rep4=$3;$str4=$4;$len4=$5;$word4=$6;
                	}
			$pname3="$name3$read3";
			$pname4="$name4$read4";
			
			$unmap3=$line3[4]=~tr/ / /;
			$unmap4=$line4[4]=~tr/ / /;
			$map3=$len3-$unmap3;
			$map4=$len4-$unmap4;
			
			my $nomapI=$unmap1+$unmap3;
        	        my $nomapII=$unmap2+$unmap4;
	                my $repI=$rep1+$rep3;
               		my $repII=$rep2+$rep4;

######################################################################################################################			
		
			if($nomapI > $nomapII){
				&getpeline(\@line2,\@line4,$word2,$word4,$str2,$str4,$name2,$name4,\*OUT);
			}	
			elsif($nomapI < $nomapII){
				&getpeline(\@line1,\@line3,$word1,$word3,$str1,$str3,$name1,$name3,\*OUT);
			}
			elsif($nomapI == $nomapII){
				if($repI>=$repII){
					&getpeline(\@line2,\@line4,$word2,$word4,$str2,$str4,$name2,$name4,\*OUT);
				}
				else{
					&getpeline(\@line1,\@line3,$word1,$word3,$str1,$str3,$name1,$name3,\*OUT);
				}
			}
				
		}
	}
	close IN;
	close OUT;	
}

sub totalID
{
	my $input=shift;
        my $output=shift;
	if($$input=~/\.gz$/){
		open IN,"gunzip -c $$input|" ||die "no input\n";
	}else{
        	open IN,$$input ||die "no input se\n";
	}
	if($$output=~/\.gz$/){
		open OUT,">:gzip","$$output"  || die "$!" ;	
	}else{
        	open OUT,">$$output" || die "can't creat output\n";
	}
	
	my $lastline=<IN>;
        chomp $lastline;
        my @array;
        push (@array,$lastline);
	

	while(<IN>){
		chomp;
		 my $line=$_;
                my @a=split /\t/,$line;
                my @b=split /\t/,$lastline;

                if($a[0] eq $b[0]){
                        push @array,$line;

                }else{
                        #print OUT $array[0]."\n";
                        if(@array==1){
				my @rawline=split(/\t/,$array[0]);
				my $rawline=join("\t",@rawline[1..$#rawline]);
                                #print OUT $array[0]."\n";
				print OUT $rawline."\n";
                        }else{
                                &gettotalline(\@array,\*OUT);
                        }
                        @array=();
                        push(@array, $line);
                }

                $lastline=$line;

        }
        close IN;
        if(@array>0){
		my @rawline=split(/\t/,$array[0]);
                my $rawline=join("\t",@rawline[1..$#rawline]);	
		print OUT $rawline."\n";
               # print OUT $array[0]."\n";
        }
        close OUT;
}

sub getpeline
{
	#>FCC01P5ACXX:8:1101:10000:102007#ACTTGAAT/      chr1W   175476920       175477026       106     >FCC01P5ACXX:8:1101:10000:102007#ACTTGAAT/1:rep1:+:len90:W  chr1     175476920       CGGGTTTTATCGTGTT                                                                                m||||||*|*m|||||                                                                             cgggtttcaccgtgttagccaggatggtctcaatctcgtgacctcgtgatccccctgcctcggcctcccaaaatgctgggattacaggcg      abbeeeeefggggheghihhhiifhiighhiiihiiiiehfghiiighgiiiiihiiiigggeacccccccccdcddccccbcccdcccc   >FCC01P5ACXX:8:1101:10000:102007#ACTTGAAT/2:rep1:-:len90:W      chr1175476936        AGTTAGGATGGTTTTAATTTCGTGATTTCGTGATTTTTTTGTTTCGGTTTTTTAAAATGTTGGGATTATAGGCGTGAGTTATTGCGTTTG      ||**||||||||*|*|||*|m||||**|m|||||*****||**|m||**|***||||||*||||||||*|||m|||||**||||m|***|   agccaggatggtctcaatctcgtgacctcgtgatccccctgcctcggcctcccaaaatgctgggattacaggcgtgagccattgcgcccg      cccccccccccbccccccccccccaccccccccceggghgiiihiiiiiiiiiiiiihiiiiiiiiiiiihgeiiiigggggeeeeebbb

	my ($lineI,$lineII,$wordI,$wordII,$strI,$strII,$readname,$readname2,$out)=@_;
	my ($len1,$len2,$start1,$start2,$end1,$end2);
	if($strI eq '+' && $strII eq '-' ||($strI eq '-' && $strII eq '+')){
	 $len1=length($$lineI[4]);
	 $len2=length($$lineII[4]);
	 $start1=$$lineI[2];
         $start2=$$lineII[2];
         $end1=$$lineI[2]+$len1-1;
         $end2=$$lineII[2]+$len2-1;

#	}elsif($strI eq '-' && $strII eq '+'){
#	 $len2=length($$lineI[4]);
#         $len1=length($$lineII[4]);
#         $start2=$$lineI[2];
#         $start1=$$lineII[2];
#         $end2=$$lineI[2]+$len1;
#         $end1=$$lineII[2]+$len2;
	}else{
		print STDERR "$strI\t$strII\t  $readname \t $readname2\t please check input that are not pe\n";
	}
	
	
	select($out);
	if($wordI eq $wordII){
		
		#if($wordI eq 'W'){			
			#if($strI eq '+'){
			 if($start2>=$start1){	
				if($start2>$end1){
					my $unmapI=$$lineI[4]=~tr/ / /;
					my $unmapII=$$lineII[4]=~tr/ / /;
					my $maptotal=$len1+$len2-$unmapI-$unmapII;
					print "$readname\t$$lineI[1]$wordI\t$$lineI[2]\t$end2\t$maptotal\t".(join "\t",@{$lineI})."\t".(join "\t",@{$lineII})."\n";	
				}elsif($end2>=$end1){
					my $overlaplen=$end1-$start2+1;#################################3#
					my $blank=" " x $overlaplen;
					my $overstart1=$len1-$overlaplen;
					my $uniq2len=$len2-$overlaplen;
					my $overstart2=0;
					my $overlap1=substr($$lineI[4],$overstart1,$overlaplen);
					my $overlap2=substr($$lineII[4],0,$overlaplen);		
					my $mapuniq1=substr($$lineI[4],0,$overstart1);
					my $mapuniq2=substr($$lineII[4],$overlaplen,$uniq2len);
					my $baseuniq1=substr($$lineI[3],0,$overstart1);
                                        my $baseuniq2=substr($$lineII[3],$overlaplen,$uniq2len);
					my $unmap_overnum1=$overlap1=~tr/ / /;
					my $unmap_overnum2=$overlap2=~tr/ / /;
					my $unmap_uniqnum1=$mapuniq1=~tr/ / /;
					my $unmap_uniqnum2=$mapuniq2=~tr/ / /;	
					
					if($unmap_overnum1<=$unmap_overnum2){
						
						my $maptotal=$overstart1+$overlaplen+$uniq2len-$unmap_uniqnum1-$unmap_uniqnum2-$unmap_overnum1;
						print "$readname\t$$lineI[1]$wordI\t$$lineI[2]\t$end2\t$maptotal\t".(join "\t",@{$lineI})."\t$$lineII[0]\t$$lineII[1]\t$$lineII[2]\t"."$blank$baseuniq2\t"."$blank$mapuniq2\t"."$$lineII[5]\t$$lineII[6]\n" ;
					}else{
						my $maptotal=$overstart1+$overlaplen+$uniq2len-$unmap_uniqnum1-$unmap_uniqnum2-$unmap_overnum2;
                                                print "$readname\t$$lineI[1]$wordI\t$$lineI[2]\t$end2\t$maptotal\t$$lineI[0]\t$$lineI[1]\t$$lineI[2]\t$baseuniq1$blank\t$mapuniq1$blank\t$$lineI[5]\t$$lineI[6]\t".(join "\t",@{$lineII})."\n" ;	
					}	
				}elsif($end2<$end1){
					my $unmapI=$$lineI[4]=~tr/ / /;
					my $maptotal=$len1-$unmapI;
					 $$lineII[4]=" " x $len2;
					print "$readname\t$$lineI[1]$wordI\t$$lineI[2]\t$end1\t$maptotal\t".(join "\t",@{$lineI})."\t".(join "\t",@{$lineII})."\n";################################
	
				}
						
			}

			#elsif($strI eq '-'){
			 else{#$start2<$start1	
				if($start1 >$end2){
					my $unmapI=$$lineI[4]=~tr/ / /;
                                        my $unmapII=$$lineII[4]=~tr/ / /;
                                        my $maptotal=$len1+$len2-$unmapI-$unmapII;
                                        print "$readname\t$$lineII[1]$wordI\t$$lineII[2]\t$end1\t$maptotal\t".(join "\t",@{$lineI})."\t".(join "\t",@{$lineII})."\n";
                                }elsif($end1>=$end2){
					#my $overlaplen=$start1-$end2+1;
					my $overlaplen=$end2-$start1+1;
					my $blank=" " x $overlaplen ;
					#die "$overlaplen\taa".$blank."\taa"."\n" ;
                                        my $overstart1=0;
					my $overstart2=$len2-$overlaplen;
                                        my $uniq1len=$len1-$overlaplen;
					my $uniq2len=$len2-$overlaplen;
					#
					my $overlap1=substr($$lineI[4],$overstart1,$overlaplen);
                                        my $overlap2=substr($$lineII[4],$overstart2,$overlaplen);
                                        my $mapuniq1=substr($$lineI[4],$overlaplen,$uniq1len);
                                        my $mapuniq2=substr($$lineII[4],0,$uniq2len);
                                        my $baseuniq1=substr($$lineI[3],$overlaplen,$uniq1len);
                                        my $baseuniq2=substr($$lineII[3],0,$uniq2len);
                                        my $unmap_overnum1=$overlap1=~tr/ / /;
                                        my $unmap_overnum2=$overlap2=~tr/ / /;
                                        my $unmap_uniqnum1=$mapuniq1=~tr/ / /;
                                        my $unmap_uniqnum2=$mapuniq2=~tr/ / /;
					#
					if($unmap_overnum1<=$unmap_overnum2){

                                                my $maptotal=$overstart1+$overlaplen+$uniq2len-$unmap_uniqnum1-$unmap_uniqnum2-$unmap_overnum1;
                                                print "$readname\t$$lineII[1]$wordI\t$$lineII[2]\t$end1\t$maptotal\t".(join "\t",@{$lineI})."\t$$lineII[0]\t$$lineII[1]\t$$lineII[2]\t$baseuniq2$blank\t$mapuniq2$blank\t$$lineII[5]\t$$lineII[6]\n" ;
                                        }else{
                                                my $maptotal=$overstart1+$overlaplen+$uniq2len-$unmap_uniqnum1-$unmap_uniqnum2-$unmap_overnum2;
                                                print "$readname\t$$lineII[1]$wordI\t$$lineII[2]\t$end1\t$maptotal\t$$lineI[0]\t$$lineI[1]\t$$lineI[2]\t$blank$baseuniq1\t$blank$mapuniq1\t$$lineI[5]\t$$lineI[6]\t".(join "\t",@{$lineII})."\n" ;
                                        }
				}elsif($end1<$end2){
					my $unmapII=$$lineII[4]=~tr/ / /;
                                        my $maptotal=$len2-$unmapII;
					$$lineI[4]=" " x $len1;
					print "$readname\t$$lineI[1]$wordI\t$$lineI[2]\t$end1\t$maptotal\t".(join "\t",@{$lineI})."\t".(join "\t",@{$lineII})."\n";

				}
		
			}	
				
	}else{
		print STDERR "$wordI\t $wordII\t $readname \t $readname2\tthis pair has not same word\n";
	}
			
		
}

sub getseline
{
#FCC01P5ACXX:8:1101:10000:165404#ACTTGAAT/      chrXC   109476729       000000000       083     FCC01P5ACXX:8:1101:10000:165404#ACTTGAAT/2:rep1:+:len90:C      chrX    109476729       CAACCTCCAACTAAAACTATTAAACCACTTTCTTCGTAACGACGACGCTAAAAAAACCAAACATAATAAACGCGAAAACCGAGATCGGAA      |##||||||#||##|#||#||#|||||||||||||m||#|m#|m||m||##|#||#|||#||||##|#|||m|m####||m#m             CGGCCTCCAGCTGGAGCTGTTGAACCACTTTCTTCGTAGCGGCGACGCTGGAGAAGCCAGACATGGTGAACGCGGGGGCCGGGCCGATTC      abbeeeeegfgegffhfdffhhiigfcggf`gfgffhiihfhfffgfdgbadgdeccacc`aabbcbbbc_VT]][T]^W[T]aaca_ac
	my ($setwo,$out)=@_;
	my @a=split /\t/,$$setwo[0];
	my @b=split /\t/,$$setwo[1];
	if(@{$setwo} != 2){
		print STDERR "something is wrong in ".join("\t",@{$setwo})."\n";
	}else{
		
		my $unmap1=$a[4]=~tr/ / /;
		my $unmap2=$b[4]=~tr/ / /;
		my $rep1;my $rep2;
		my ($readname1,$readname2,$word1,$word2,$strand1,$strand2,$len1,$len2,$strand1,$stand2);
		if($a[0]=~/^(\S+)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
			$readname1=$1;$rep1=$3;$strand1=$4;$len1=$5;$word1=$6;
		}
		if($b[0]=~/^(\S+)(\d)\:rep(\d+)\:(\S)\:len(\d+)\:(\w)/){
			$readname2=$1;$rep2=$3;$strand2=$4;$len2=$5;$word2=$6;
		}
		my $map1=$len1-$unmap1;
		my $map2=$len2-$unmap2;
		if($map1>$map2){
		  if($strand1 eq '+'){
			print $out "$readname1\t$a[1]$word1\t$a[2]\t0\t$map1\t$$setwo[0]\n";
		  }elsif($strand1 eq '-' ){
			my $end=$a[2]+$len1-1;
			print $out "$readname1\t$a[1]$word1\t0\t$end\t$map1\t$$setwo[0]\n";	
		  }
		}elsif($map1<$map2){
		  if($strand2 eq '+'){
				
			print $out "$readname2\t$b[1]$word2\t$b[2]\t0\t$map2\t$$setwo[1]\n";
		  }elsif($strand2 eq '-' ){
			my $end=$b[2]+$len2-1;
			print $out "$readname2\t$b[1]$word2\t0\t$end\t$map2\t$$setwo[1]\n";
		  }
		}elsif($unmap1==$unmap2){
			if($rep1>$rep2){
			  if($strand2 eq '+'){
				print $out "$readname2\t$b[1]$word2\t$b[2]\t0\t$map2\t".$$setwo[1]."\n";
			  }elsif($strand2 eq '-'){
				my $end=$b[2]+$len2-1;
				print $out "$readname2\t$b[1]$word2\t0\t$end\t$map2\t$$setwo[1]\n";
			  }
			}else{
			  if($strand1 eq '+'){
				print $out "$readname1\t$a[1]$word1\t$a[2]\t0\t$map1\t$$setwo[0]\n";
			  }elsif($strand1 eq '-'){
				my $end=$b[2]+$len2-1;
				print $out "$readname1\t$a[1]$word1\t0\t$end\t$map1\t$$setwo[0]\n";		
			  }			  
			}
		}				
	}
}

sub gettotalline
{
	my ($setwo,$out)=@_;
	my @a=split /\t/,$$setwo[0];
	my @b=split /\t/,$$setwo[1];
	if(@{$setwo}==3){
		if(@a>14){
			my @rawline=split(/\t/,$$setwo[0]);
	                my $rawline=join("\t",@rawline[1..$#rawline]);
			#print $out $$setwo[0]."\n";
			print $out $rawline."\n";
			
		}elsif(@b>14){
			my @rawline=split(/\t/,$$setwo[1]);
	                my $rawline=join("\t",@rawline[1..$#rawline]);
			#print $out $$setwo[1]."\n";
			 print $out $rawline."\n";
			
		}else{
			my @rawline=split(/\t/,$$setwo[2]);
                        my $rawline=join("\t",@rawline[1..$#rawline]);
			#print $out $$setwo[2]."\n";
			print $out $rawline."\n";
		}
	}	
	if(@{$setwo}==2){
		 if(@a>14){
                        my @rawline=split(/\t/,$$setwo[0]);
                        my $rawline=join("\t",@rawline[1..$#rawline]);
                        #print $out $$setwo[0]."\n";
			 print $out $rawline."\n";

                }elsif(@b>14){
                        my @rawline=split(/\t/,$$setwo[1]);
                        my $rawline=join("\t",@rawline[1..$#rawline]);
                        #print $out $$setwo[1]."\n";
			 print $out $rawline."\n";

                }else{
			my $rawline1=join("\t",@a[1..$#a]);
			my $rawline2=join("\t",@b[1..$#b]);
                        #print $out $$setwo[2]."\n";
			print $out "$rawline1\n$rawline2\n";	
                }
        }
	
}

sub usage
{

die "perl $0 --mode <pe/se/total> in out\n";

}

