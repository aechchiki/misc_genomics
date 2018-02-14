awk '{
	n11 = split($11, t11, ",")
	n12 = split($12, t12, ",")
	for (i = 0; ++i < n11 - 1;) {
		s12 = $2 + t12[i]
		print $1, s12 + t11[i], $2 + t12[i + 1], i "I_" $4 }
	}' $1
