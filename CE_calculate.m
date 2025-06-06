function ce = CE_calculate(I1,I2,I3)

ce1 = cross_entropy(I1,I2);
ce2 = cross_entropy(I1,I3);
ce  = (ce1+ce2)/2;

end

