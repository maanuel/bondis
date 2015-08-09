classdef Recorrido < handle
    % Modelamos al recorrido como si fuese una transformacion lineal que
    % retorna puntos de una recta que une el inicio y el final [0,1].
    % TODO: Es necesario contemplar que no simpre el recorrido es una recta
    % En todo caso union de varias rectas.
    
    properties
        
        inicioOrig
        finOrig
        
        inicioPlano
        finPlano
        
        m % vector pendiente
        b % ordenada al origen
    end
    
    methods
        function obj = Recorrido(inicio, fin, tipo)
            % nos pasan posiciones geograficas
            if tipo == 0
                % las pasamos a plano
                 obj.inicioOrig = inicio;
                 obj.finOrig = fin;
                 obj.inicioPlano = lla2ecef(inicio')';
                 obj.finPlano = lla2ecef(fin')';
                 obj.inicioPlano = obj.inicioPlano(1:2,1);
                 obj.finPlano = obj.finPlano(1:2,1);
            else
                % ya son un plano
                % En este caso no va haber una tercera posición z.
                obj.inicioPlano = inicio;
                obj.finPlano = fin;
            end
            
            obj.m = obj.finPlano - obj.inicioPlano;
            obj.b = obj.inicioPlano;
        end
        
        function pos = posicion(obj,p)
            % me dan un p, quiero saber a que punto corresponde
            % p debe estar entre 0 y 1
            pos = obj.m*p+obj.b;
        end
        
        function p = porcentaje(obj,pos)
            % me dan un vector posición y obtengo el coeficiente de la
            % proyección ortogonal de pos en la recta generada por m.
            % pos = x' + m * p 
            % x', m vectores - p escalar.
            
            % lo llevamos al origen
            pos = pos - obj.inicioPlano;
            p = (pos'*obj.m)/(norm(obj.m)^2);
            
            % buscamos vector perpendicular 
            %y = [1;0];
            %y(2) = -obj.m(1)/ obj.m(2);
            
            % llevamos pos al origen
            % y lo descomponemos con la recta que une inicio y fin
            %A = [obj.m y];
            %B = pos-obj.inicioPlano;

            %X = A\B;
            
            %p = X(1);
        end
    end
    
end

