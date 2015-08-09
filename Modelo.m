classdef Modelo < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        colectivos
        cv
        recorrido
    end
    
    methods (Abstract)
        predecir(obj, colectivoId, k) % cada modelo debe implementar su método de predicción.
    end

    methods
        function obj = Modelo(recorrido) % constructor
            obj.recorrido = recorrido;
            % cargamos todos los colectivos al a memoria
            listing = dir('*output*.txt');
            colectivos(length(listing)) = Colectivo();
            for i=1:length(listing)
                colectivos(i) = Colectivo(listing(i).name, recorrido);
            end
            obj.colectivos = colectivos;
            % podriamos customizar cuantos folds usar...
            obj.cv = cvpartition(length(listing), 'KFold');
        end
        
        function res = run(obj)
            tic
            % res es una matriz que tiene los resultados de cada predicción
            % del test para cada fold
            % row iesima -> iesimo fold
            
            K = obj.cv.NumTestSets;
            res = zeros(obj.cv.NumTestSets, max(obj.cv.TestSize));
            
            
            for i=1:K % recorremos cada particion
                contador = 1;
                testing = test(obj.cv, i);
                % a cada colectivo en el test, lo intentamos predecir...
                for j=1:length(testing)
                    if testing(j) == 1
                        % lo predecimos
                        tiempo = predecir(obj, j, i);
                        res(i,contador) = tiempo;
                        contador = contador+1;
                    end
                end
            end
           
        end
        disp(toc);
    end
    
end

