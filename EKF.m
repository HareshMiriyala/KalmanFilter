% IMPLEMENTATION OF EXTENDED KALMAN FILTER
clear all;clc;close all;
rho_0 = 3.4e-3;
g = 32.2;
k_rho = 22000;
P_0 = diag([500 2*10^4 2.5*10^5]);
u_0 = [10^5;-6000;2000];
R_t = [0 0 0;0 2 0;0 0 0];
Q_t = 100;
H_t = [1 0 0];
tf=20;
dt=0.1;
t = 0:dt:tf;
%calculate the Jacobian matrix
syms x y z real
G = jacobian([y*dt+x;y+dt*(-g+rho_0*exp(-x/k_rho)*y^2/(2*z));z],[x;y;z]);
figure
j=1;s_u=[u_0];P_t(:,:,1)=P_0;
tic
for time=t
    % find the mean prediction
    s_u(:,j+1) = gmeanfunc(s_u(:,j),dt);
    % find the covariance prediction
    G_t(:,:,j+1) = (subs(G,[x y z],[s_u(1,j+1) s_u(2,j+1) s_u(3,j+1)]))';
    P_t(:,:,j+1) = G_t(:,:,j+1)*P_t(:,:,j)*G_t(:,:,j+1)' + dt^2.*R_t;
    K_t(:,:,j+1) = P_t(:,:,j+1)*H_t'*(H_t*P_t(:,:,j+1)*H_t'+ Q_t)^-1;
    zm(j) = normrnd(s_u(1,j+1),100);
    u_upd(:,j) = s_u(:,j+1)+K_t(:,:,j+1)*(zm(j)-s_u(1,j+1));
    P_upd(:,:,j+1) = (eye(3)-K_t(:,:,j+1)*H_t)*P_t(:,:,j+1);
    j=j+1;
end
toc
plot(0:dt:tf,zm,'-b',0:dt:tf,u_upd(1,:),'-r')
legend('measured state','filtered state')
xlabel('Time (sec)');
ylabel('x1 (feet)');

function snext = gmeanfunc(s,dt)
rho_0 = 3.4e-3;g = 32.2;
k_rho = 22000;
snext=zeros(3,1);
snext(1,1) = s(2)*dt + s(1);
snext(2,1) = s(2) + dt*(-g+rho_0*exp(-s(1)/k_rho)*s(2)^2/(2*s(3)));
snext(3,1) = s(3);
end