use strict;
my $i=shift;
open IN,$i or die "no vcffile\n";
#chr1    763080  .       G       A,T,X   128     .       DP=128;VDB=0.0000;AF1=0.5;CI95=0.5,0.5;DP4=68,0,60,0;MQ=42;FQ=131;PV4=1,1,1,1
while(<IN>){
	chomp;
	next if(/\#/);
	my @a=split;
	my @b=split /\:/,$a[9];
		
		my @num=split /\,/,$b[7];
		#print join("\t",@num)."\n";
		my $ref1num=$num[0];
		my $ref2num=$num[1];
		my $var1num=$num[2];
		my $var2num=$num[3];
		my $refnum=$ref1num+$ref2num;
		my $varnum=$var1num+$var2num;
		my $total=$refnum+$varnum;
		next if($total<10);
		my $varfreq=$varnum/$total;
		next if($varfreq<0.2);
		next if($varfreq>0.85);
		print $_."\n";
}
close IN;
