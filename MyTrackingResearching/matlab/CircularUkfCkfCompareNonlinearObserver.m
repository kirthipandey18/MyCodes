f = @(x,param) ...
    [1 sin(x(5)*param(1))/x(5)      0 -((1-cos(x(5)*param(1)))/x(5)) 0;
     0 cos(x(5)*param(1))           0 -sin(x(5)*param(1))            0;
     0 (1-cos(x(5)*param(1)))/x(5)  1 sin(x(5)*param(1))/x(5)        0;
     0 sin(x(5)*param(1))           0 cos(x(5)*param(1))             0;
     0 0                            0 0                              1]*x;
h = @(x, params) ...
    [sqrt(x(1,:).^2+x(3,:).^2);
     atan2(x(3,:),x(1,:))];

dt = 1;
radius = 100;
delta = 2*pi/360*5.73*0.5;
count = 62;

txs = zeros(2, count);
uxs = zeros(5, count);
cxs = zeros(5, count);

x0 = [100 0 0 5 0.05]';
P0 = diag([100 10 100 10 100]);

M_ukf = x0;
P_ukf = P0;
M_ckf = x0;
P_ckf = P0;

Qv = [0.1/3     0.1/2   0         0         0;
      0.1/2     0.1     0         0         0;
      0         0       0.1/3     0.1/2     0;
      0         0       0.1/2     0.1       0;
      0         0       0         0         1.75];

Qw = diag([25 0.001]);

for i=1:count
    fprintf('==================��%d��======================\n',i);
    
    target_pos_x = cos(i*delta)*radius + randn(1)*0.0001;
    target_pos_y = sin(i*delta)*radius + randn(1)*0.0001;
    txs(:,i) = [target_pos_x; target_pos_y];
    
    zx = sqrt(target_pos_x^2 + target_pos_y^2)+randn(1)*5;
    zy = atan2(target_pos_y,target_pos_x);
    
    [M_ukf, P_ukf,D,upSX,upSY] = ukf_predict1(M_ukf, P_ukf, f, Qv, dt,1,1,-2);
    [M_ukf, P_ukf,uK,uMU,uS,uLH,uuSx,uuSY] = ukf_update1(M_ukf, P_ukf, [zx; zy], h, Qw);
    
    [M_ckf, P_ckf,cpSX,cpSY] = ckf_predict(M_ckf, P_ckf, f, Qv, dt);
    [M_ckf, P_ckf,cK,cMU,cS,cLH,cuSx,cuSY] = ckf_update(M_ckf, P_ckf, [zx; zy], h, Qw);
    
%     fprintf('predict �任ǰ Sigma/Cubature ��Ƚϣ�\n');
%     upSX
%     cpSX
%     fprintf('predict �任�� Sigma/Cubature ��Ƚϣ�\n');
%     upSY
%     cpSY
%     fprintf('update �任ǰ Sigma/Cubature ��Ƚϣ�\n');
%     uuSx
%     cuSx
%     fprintf('update �任�� Sigma/Cubature ��Ƚϣ�\n');
%     uuSY
%     cuSY

    fprintf('CKF���������棺');
    cK
    
    fprintf('Ŀ����ʵλ��:(%f,%f)\n',zx,zy);
    fprintf('UKF CKF ��������\n');
    M_ukf
    M_ckf
    
    uxs(:,i) = M_ukf;
    cxs(:,i) = M_ckf;
    fprintf('==============================================\n');
end

plot(txs(1,:), txs(2,:), uxs(1,:), uxs(3,:), cxs(1,:), cxs(3,:));
legend('True','UKF','CKF');
