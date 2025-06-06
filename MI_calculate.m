function mi = MI_calculate(I1,I2,I3)

mi1 = mutinf(I1,I2);
mi2 = mutinf(I1,I3);
mi = mi1 + mi2;

end

