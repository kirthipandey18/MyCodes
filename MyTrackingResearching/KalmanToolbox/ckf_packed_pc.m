function pc = ckf_packed_pc(x,fmmparam)
% CKF_PACKED_PC - Pack P and C for the Cubature Kalman filter transform
%
% Syntax:
%   pc = CKF_PACKED_PC(x,fmmparam)
%
% In:
%   x - Evaluation point
%   fmmparam - Array of handles and parameters to form the functions.
%
% Out:
%   pc - Output values
%
% Description:
%   Packs the integrals that need to be evaluated in nice function form to
%   ease the evaluation. Evaluates P = (f-fm)(f-fm)' and C = (x-m)(f-fm)'.

% Copyright (c) 2010 Hartikainen, Särkkä, Solin
%
% This software is distributed under the GNU General Public
% Licence (version 2 or later); please refer to the file
% Licence.txt, included with the software, for details.
%%

  f  = fmmparam{1};     % ��̬����
  m  = fmmparam{2};     % ��һʱ�̺���
  fm = fmmparam{3};     % ��S-R׼����õ���һʱ�̵��������
  if length(fmmparam) >= 4
      param = fmmparam{4};
  end

  % �������x�����ݻ��㣬��f��S-R��һ����
  % ����Ҳ�����ݻ���ʹ�ö�̬����f��ȡֵ
  if ischar(f) || strcmp(class(f),'function_handle')
      if ~exist('param','var')
         F = feval(f,x);
      else
         F = feval(f,x,param);
      end
  elseif isnumeric(f)
         F = f*x;
  else
      if ~exist('param','var')
         F = f(x);
      else
         F = f(x,param);
      end
  end
  d = size(x,1);   % �ݻ�����
  s = size(F,1);    % ȡֵ������������һ����
  % ����ʵ�⣬d��4��s��2,ԭ�������������������ġ�

  % Compute P = (f-fm)(f-fm)' and C = (x-m)(f-fm)'
  % and form array of [vec(P):vec(C)]
  pc = zeros(s^2+d*s,size(F,2));
  P = zeros(s,s);
  C = zeros(d,s);
  % ������ÿ�����ݻ��㴦��ȡֵ
  for k=1:size(F,2)
    for j=1:s
      for i=1:s
          % ���������Э����
          % ��������P��C�Ĺ�ʽ���ڶ�������ǲ���Ӧ�ü�һ��'�أ�
          % Ĭ����û�мӵ�
          % �Ҹ������������ˣ���֪����û��Ч�����Ȼ�����֤��
          % ����֤��һ�Σ�����ȷʵ�Ǹ�BUG���Ҽ���ת�ú󣬾����ǶԳ����ˡ�
          P(i,j) = (F(i,k)-fm(i)) * (F(j,k) - fm(j))';
%           P(i,j) = (F(i,k)-fm(i)) * (F(j,k) - fm(j));
      end
      for i=1:d     
          C(i,j) = (x(i,k)-m(i)) * (F(j,k) - fm(j))';
%           C(i,j) = (x(i,k)-m(i)) * (F(j,k) - fm(j));
      end
    end
    % ��������������ôһ�����󣬾��ǼȰ�����Э���Ҳ�������Э����
    pc(:,k) = [reshape(P,s*s,1);reshape(C,s*d,1)];
  end
  