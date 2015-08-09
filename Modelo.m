classdef Modelo < handle
    %Clase Abstracta para comparar los distintos criterios de predicciones.
    %   Cada subclase deberá definir el método predecir.
    
    properties
        colectivos % los cargamos una vez a la memoria, evitamos levantar muchas veces el mismo archivo.
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
        
        % Ejecuta el modelo y devuelve los errores de predicción en una
        % matriz.
        % Por cada fila, se encuentran los errores de cada elemento del
        % test.
        % Hay tantas filas como folds (por defecto es 10)
        % Hay tantas columnas, como elementos en el test.
        % A veces hay un 0, porque no todos los test set tienen la misma
        % dimensión.
        % TODO: Sería útil retornarla traspuesta, por como funciona la
        % función mean.
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

