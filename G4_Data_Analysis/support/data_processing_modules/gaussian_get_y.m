function est_y = gaussian_get_y(x, coeffs)

est_y = coeffs(1)*exp(-((x-coeffs(2))/coeffs(3)).^2);

end