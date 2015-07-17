function distance = KL_distance(mu1, cov1, mu2, cov2)
% DIST = KL_distance(MU1, COV1, MU2, COV2)

d = length(mu1);  % dimension of multivariate gaussian


if det(cov1) == 0 || det(cov2) == 0
    ln_cov_pq = 0;  % prevent NaN (div by 0) and -Inf (log 0)
    ln_cov_qp = 0;
else 
    ln_cov_pq = log(det(cov2)/det(cov1));
    ln_cov_qp = log(det(cov1)/det(cov2));
end

trcov_pq = trace(cov2\cov1);
trcov_qp = trace(cov1\cov2);
musq_pq = (mu1-mu2)*(cov2\(mu1-mu2)');
musq_qp = (mu2-mu1)*(cov1\(mu2-mu1)');

twoKL_pq = ln_cov_pq + trcov_pq + musq_pq - d;
twoKL_qp = ln_cov_qp + trcov_qp + musq_qp - d;

distance = 0.5*(twoKL_pq + twoKL_qp);



