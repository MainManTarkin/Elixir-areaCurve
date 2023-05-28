defmodule MathTerm do

    def evlaTerm(mapInput, xInput)  do
        
        Enum.map(mapInput, fn x -> 
           
                x.coefficient * :math.pow(xInput, x.exponent)
                end
        ) |>
        Enum.reduce(0.0, fn x, acc -> x + acc end)
        
        
        
    end

    def add_term(coffInput,expInput, mapInput) do
        
       newMap = makeMap(coffInput, expInput)
       List.insert_at(mapInput,0, newMap)

    end

    defp makeMap(coffInput,expInput) do
        
        newMap = %{:coefficient => coffInput, :exponent => expInput}
        newMap
    end

    def mapStringOut(listInput) do
        
        Enum.each(listInput, fn x -> mapStringHelper(x.coefficient, x.exponent)  
        indexOfCurrentTerm = Enum.find_index(listInput, fn y -> y == x end)
        writePlus((indexOfCurrentTerm != (length(listInput) - 1)))
        end)

    end

    defp writePlus(true) do
        
        IO.write("+ ")

    end

    defp writePlus(false) do
        

    end

    defp mapStringHelper(1.0, expInput)   do
        
        IO.write("x^#{expInput} ")

    end

    defp mapStringHelper(coffInput, 1.0)   do
        
        IO.write("#{coffInput}x ")

    end

    defp mapStringHelper(coffInput, 0.0)   do
        
        IO.write("#{coffInput} ")

    end

    defp mapStringHelper(coffInput, expInput)   do
        
        IO.write("#{coffInput} * x^#{expInput} ")

    end
end

defmodule Integrals do
    
    def evaluate(math_function, start_x, end_x, delta) when delta < end_x do
        
        numProcesses = System.schedulers_online()
        xDiffrence = end_x - start_x
        splitWork = xDiffrence / numProcesses

        makeProccess(math_function, start_x, splitWork, delta, numProcesses)

        await_children(numProcesses,0)
       
    end

    def to_S(math_function, start_x, end_x, delta) do
        
        curveArea = evaluate(math_function, start_x, end_x, delta)

        IO.write("Area under the curve of ")
        MathTerm.mapStringOut(math_function)
        IO.write("from #{start_x} to #{end_x}: #{curveArea} \n")


    end

    defp await_children(0, results) do
        results
    end
    
    defp await_children(num_children, results) do
        child_result = receive do
          {:done, result} -> result
        end
        await_children(num_children - 1, results + child_result)
    end

    def aProcess(argsInput) do
        
        parentId = Enum.at(argsInput, 0)
        startX = Enum.at(argsInput, 1)
        splitWork = Enum.at(argsInput, 2)
        delta = Enum.at(argsInput, 3)
        math_function = Enum.at(argsInput, 4)
        processId = Enum.at(argsInput, 5)

        startPoint = startX + (splitWork  * processId)
        endPoint = startPoint + splitWork

     
        totalArea = calcRecurse(math_function, startPoint, delta, 0.0, endPoint)
        
        send(parentId, {:done, totalArea})

    end

    defp calcRecurse(mathFuncInput, startPointInput, deltaInput, totalAreaInput, endPointInput) when startPointInput < endPointInput do

        totalAreaInput = totalAreaInput + calculateArea(mathFuncInput, startPointInput,deltaInput)
        calcRecurse(mathFuncInput,(startPointInput + deltaInput),deltaInput,totalAreaInput,endPointInput)

    end

    defp calcRecurse(_mathFuncInput, startPointInput, _deltaInput, totalAreaInput, endPointInput) when startPointInput >= endPointInput do
        totalAreaInput
    end

    defp calculateArea(mathFunctionInput, xInput,deltaInput) do
        
        height = MathTerm.evlaTerm(mathFunctionInput, xInput)
        
        deltaInput * height
        
    end

    defp makeProccess(math_function, startXInput, splitWorkInput, deltaInput, processCountInput) do
        
        Enum.each(0..processCountInput-1, fn x -> spawn(Integrals, :aProcess , [[self(), startXInput, splitWorkInput, deltaInput, math_function, x]]) end)

    end

end




termList = MathTerm.add_term(4.0,0.0,[])
termList = MathTerm.add_term(3.0,1.0,termList)
termList = MathTerm.add_term(1.0,2.0,termList)


Integrals.to_S(termList, 1, 2, 0.00001)