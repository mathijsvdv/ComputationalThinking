function find_energy(img)

    energy_x = imfilter(brightness.(img), Kernel.sobel()[2])
    energy_y = imfilter(brightness.(img), Kernel.sobel()[1])

    return sqrt.(energy_x.^2 + energy_y.^2)
end

function find_energy_map(energy)

    sz = size(energy)
    energy_map = zeros(size(sz))
    energy_map[end,:] = energy[end,:]

    next_elements = zeros(Int, sz)
    
    for i in sz[1]-1:-1:1, j in sz[2]
        left = max(1, j-1)
        right = min(j+1, sz[2])
        local_energy, next_element = findmin(energy_map[i+1, left:right])
        
        # Minimal energy to bottom
        energy_map[i,j] += local_energy + energy[i,j]
        
        # Element that minimizes the energy
        next_elements[i,j] = next_element - 2

        if left == 1
            next_elements[i,j] += 1
        end
    end

    return energy_map, next_elements
end

"""
Just looks up the minimal path from the `next_elements` array. 
"""
function find_seam_at(next_elements, element)

    seam = zeros(Int, size(next_elements)[1])
    seam[1] = element
    for i = 2:length(seam)
        seam[i] = seam[i-1] + next_element[i, seam[i-1]]
    end

    return seam
end


function find_seam(energy)

    energy_map, next_elements = find_energy_map(energy)

    _, min_element = findmin(energy_map[1,:])

    return find_seam_at(next_elements, min_element)
end