classdef ModeloA < Modelo
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pObs % porcentaje de obs usadas para simular
    end
    
    methods
        function obj = ModeloA(recorrido, porcentajeObs) % constructor
            obj@Modelo(recorrido);
            obj.pObs = porcentajeObs;
        end
             
        function tiempo = predecir(obj, colectivoId, k)
            c1 = obj.colectivos(colectivoId);
            nroObs = round(length(c1.t_norm)/obj.pObs);
            
            similar = hallarSimilar(obj, colectivoId, k, nroObs);
            
            c2 = obj.colectivos(similar);
            % hago predicción con el similar que encontré
                 
            generarPredictor(c2, 1, length(c2.t_norm));
            generarPredictor(c1,1, length(c1.t_norm));

            t0 = arribo(c1, c1.proyecciones(nroObs));
            tend = arribo(c1, 1);
            d1 = tend-t0;
            t0 = arribo(c2, c1.proyecciones(nroObs));
            tend = arribo(c2, 1);
            d2 = tend-t0;

            tiempo = abs(d2-d1);
        end
    end
    
    
end

function dist = comparar( c1, c2, obs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% cuantos observaciones consideramos
% en este caso la mitad
%nroObs = round(length(c1.t_norm)/obs);
nroObs = obs;

% cuadrados minimos sobre la cantidad supuesta
generarPredictor(c1,1, nroObs);
% estimamos entrada al tramo
t0 = arribo(c1,0);

% la ultima observacion que tenemos.
tend = c1.t_norm(nroObs);

% NOTA: No podemos comparar entre observaciones de distintos colectivos
% Cada colectivo pudo haber entrado al tramo, desde distintos porcentajes.

% c2 es el colectivo que ya tenemos guardado
generarPredictor(c2,1, length(c2.t_orig));
t_0 = arribo(c2, 0);


% construimos polinomio normalizador de instantes, para ser comparados.
% Si tenemos para c1, una observaciones de t segundos luego de t0, buscamos
% el mismo con respecfto a t_0
C = t_0 - t0;
C = [1 C];

%plotPrediccion(c1, 0, tend);
%hold on;
%plotPrediccion(c2, t_0-t0, tend -t0 + t_0);

% Matlab no me sabe dar los coeficientes de una composicion de polinomios,
% entonces tampoco lo puedo integrar.
% Evaluamos la composicion en ciertos puntos, para poder determinarlo luego
% univocamente.
nroCoefs = length(c2.prediccion);
values = zeros(1,nroCoefs);
for i = 1:nroCoefs
    x = polyval(C, i);
    y = polyval(c2.prediccion, x);
    values(i) = y;
end

A = c1.prediccion;
B = polyfit([1:nroCoefs], values, nroCoefs-1);

PRODUCTO = sum_poly_coeff(A,B*(-1));
PRODUCTO = conv(PRODUCTO, PRODUCTO);

INTEGRAL = polyint(PRODUCTO);

dist = polyval(INTEGRAL, tend) - polyval(INTEGRAL, t0);
end

function [ similar similitud ] = hallarSimilar(model, colectivoId, K, nroObs)

    min = 0;
    %name = '';
    colId = 0;
    
    train = training(model.cv, K);
    c1 = model.colectivos(colectivoId); % usamos referencia ya cargada en memoria.
    
    for i=1:length(train)    
        if (train(i) == 0 || strcmp(c1.name, model.colectivos(i).name))
            continue;
        end

        %c2 = Colectivo(listing(i).name, r);
        c2 = model.colectivos(i);
        
        dist = comparar(c1, c2, nroObs);
        if min == 0 || min > dist
            min = dist;
            colId = i;
            %name = listing(i).name;
        end
    end

    similar = colId;
    similitud = min;

end
