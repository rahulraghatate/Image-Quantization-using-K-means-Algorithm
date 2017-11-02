clc;
clear;

ip=input('Enter source file name ','s');
op=input('Enter output file name ','s');
level=input('Enter quantization levels for each colour ');
iterations=input('Enter iterations ');

a=imread(ip);
[h,y,col]=size(a);
e=double(a);

for color=1:col
    for b=1:level
        codebook(b,1,color)=((256/level)*b)-1;
        for i=h*y
            group(b,i,color)=0;
        end
    end
end
    
for color=1:col
    for iter=1:iterations
        for i=1:level
            k(i,color)=1;
        end
        for c=1:h
            for d=1:y
                distortion=256*256;
                for b=1:level
                    test=(codebook(b,1,color)-e(c,d,color))^2;
                    if (test<distortion)
                        distortion = test;
                        bb=b;                        
                    end
                end
                group(bb,k(bb,color),color)=e(c,d,color);
                        k(bb,color)=k(bb,color)+1;
            end
        end
        for b=1:level
            if (k(b,color)>1)
                k(b,color)=k(b,color)-1;
            end
        end
        for b=1:level
            codebook(b,1,color)=0;
            for x=1:k(b,color)
                codebook(b,1,color)= codebook(b,1,color)+group(b,x,color);
            end
            codebook(b,1,color)=codebook(b,1,color)/k(b,color);
        end
    end
end
figure(1)
image(a);
%lookup=uint8(codebook);

%encoding
for color=1:col
    for c=1:h
        for d=1:y
            distortion=256*256;
            for b=1:level
                test=(codebook(b,1,color)-e(c,d,color))^2;
                if (test<distortion)
                    distortion =test;
                end
            end
            for b=1:level
                test=(codebook(b,1,color)-e(c,d,color))^2;
                if (distortion==test)
                    ncode(c,d,color)=b;
                    break;
                end
            end
            
        end
    end
end

%decoding
for color=1:3
    for c=1:h
        for d=1:y
            f(c,d,color)=codebook(ncode(c,d,color),1,color);
        end
    end
end
new=uint8(f);
%figure(2)
%image(new);
%imwrite(new,op,'jpg');

%distortion plot
for color=1:col
    j=1;
    for c=1:h
        for d=1:y
            noise(j,color)=(e(c,d,color)-f(c,d,color))^2;
            j=j+1;
        end
    end
end
figure(3)

j=1:h*y;
    subplot(3,1,1);
    plot(noise(j,1));
    xlabel('Element Index');
    ylabel('Distortion');
    
    subplot(3,1,2);
    plot(noise(j,2));
    xlabel('Element Index');
    ylabel('Distortion');
    subplot(3,1,3);
    plot(noise(j,3));
    xlabel('Element Index');
    ylabel('Distortion');
%image(a);

for color=1:col
    sum(color)=0;
    for i=1:h*y
        sum(color)=sum(color)+noise(i,color);
    end
    sum(color)=sqrt(sum(color))/(h*y);
end

disp(sum);