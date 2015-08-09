classdef Colectivo < handle
    %Colectivo Esta clase representa un bondi.
    %   Almacenamos sus observaciones, las mismas pasadas a un plano, su
    %   polinomio para predicción y distintos métodos para el análisis.
    
    properties
    % en cada fila almacenamos latitud, longitud, altitud
    movimientosGeo
    % los valores anteriores a un plano
    movimientosPlano
    % porcentajes del recorrido correspondientes a cada observacion
    proyecciones
    % tiempos de cada observacion - unixepoch
    t_orig
    % tiempos de cada observacion - normalizados
    % la primera es la 0 y sucesivamente los deltas.
    t_norm
    % polinomio generado al simular el recorrido con cuadrados minimos
    prediccion
    % grado del polinomio
    grado
    name
    end
    
    methods
        function obj = Colectivo(fileName, recorrido)
            if nargin == 0
                return;
            end
            obj.name = fileName;
            obj.grado = 0;
            % levantamos el archivo asociado al colectivo a construir
            [ obj.t_orig obj.t_norm obj.movimientosGeo obj.movimientosPlano] = parsearBondi(fileName);
            
            % cada posición en el plano la proyectamos al recorrido
            for i = 1:size(obj.movimientosPlano,1)
                pos = obj.movimientosPlano(i,:);
                p = porcentaje(recorrido, pos');
                obj.proyecciones = horzcat(obj.proyecciones,p);  
            end
            % para ser consitentes
            obj.proyecciones = obj.proyecciones';
            
            %generarPredictor(obj, 2);
            %scatterObs(obj);
            %hold on;
            %plotPrediccion(obj,0,obj.t_norm(end));
            %hold on;
            %generarPredictor(obj,1);
            %plotPrediccion(obj,0,obj.t_norm(end));
            %disp(arribo(obj,0.5));
                       
        end
        function scatterObs(obj)
            scatter(obj.t_norm, obj.proyecciones);           
        end
        function plotPrediccion(obj,t0, t1)
            x = linspace(t0, t1);
            y = polyval(obj.prediccion, x);
            plot(x,y);
        end
        % VERIFICAR QUE AL MENOS SE LLEGUE AL Y=0, Y=1.
        % SINO NO ES CONSISTENTE
        function generarPredictor(obj, grado, nroObs)
            obj.grado = grado;
            % generamos polinomio predictor
            t = obj.t_norm';
            p = obj.proyecciones';
            obj.prediccion = polyfit(t(1, 1:nroObs), p(1, 1:nroObs), obj.grado);
            
            % TODO: calcular arribo para 0 e 1, tienen que haber solucion
            % real para cada caso.
        end
        
        function r = arribo(obj, p)
            pol = obj.prediccion;
            pol(end) = pol(end)-p;
            r = roots(pol);
        end
    end
    
end

function [ T_ORIGINALES T_NORMALIZADOS POSICIONES_ORIGINALES POSICIONES_PLANO] = parsearBondi( name )
    % parsea un archivo que tiene como colulmas:
    % unixepoch Latitud Longitud Altitud (no se bien el orden de latitud
    % longitud)
    
    % pasa las coordenadas a las de un plano y normaliza los tiempos
    
    % levanto archivo
    R = csvread(name);
    
    T_ORIGINALES = R(:,1);
    POSICIONES_ORIGINALES = R(:,2:4);
    
    
    % las ultimas 3 columnas tienen coordenadas
    P = lla2ecef(R(1:end,[2,3,4]));
    
    POSICIONES_PLANO = P(:,1:2);
    
    t = R(:,1);

    for i = 2:length(t)
        t(i) = (t(i) - t(1));
    end

    t(1) = 0;
    
    T_NORMALIZADOS = t;
    
end


