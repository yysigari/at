import at
import at.plot
import numpy as np
import matplotlib.pyplot as plt


file_path = 'dba.mat'
# Load lattice file (can be .mat or .lat)
lattice = at.load_mat(file_path, mat_key='RING')
plt.rcParams["figure.figsize"] = [10, 6]
plt.rcParams["figure.dpi"] = 600
plt.rcParams['lines.linewidth'] = 6

plt.rcParams["xtick.direction"] = 'inout'
plt.rcParams["ytick.direction"] = 'inout'
plt.rcParams["xtick.minor.visible"] = True
plt.rcParams["ytick.minor.visible"] = True

plt.rcParams['xtick.major.size'] = 10
plt.rcParams['ytick.major.size'] = 10

plt.rcParams['xtick.minor.size'] = 5
plt.rcParams['xtick.labelsize'] = 24
plt.rcParams['ytick.labelsize'] = 24
plt.rcParams['xtick.top'] = True
plt.rcParams['ytick.right'] = True
plt.rcParams['axes.titlesize'] = 26
plt.rcParams['font.size'] =20
plt.rcParams['lines.linewidth'] = 2.3
plt.rcParams['font.family']= 'Times New Roman'
plt.rcParams['legend.loc']= 'upper right'
plt.rcParams['legend.fontsize']= 'small'
plt.rcParams['xtick.major.width']=1
plt.rcParams['ytick.major.width']=1
plt.rcParams['axes.grid'] = False
plt.rcParams['axes.grid.which'] = 'major'
custom_colors = ['blue', 'red', 'green']
# Set the custom color cycle
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=custom_colors)
# Plot beta functions
lattice.plot_beta(s_range=[0,24])

# Step 2: Generate initial particle positions using a Gaussian distribution
x = np.random.normal(0, sigma_x, num_particles)  # x position
y = np.random.normal(0, sigma_y, num_particles)  # y position
z = np.zeros(num_particles)                      # z position (assumed zero for simplicity)
px = np.random.normal(0, sigma_px, num_particles) # x momentum
py = np.random.normal(0, sigma_py, num_particles) # y momentum
pz = np.random.normal(0, sigma_pz, num_particles) # z momentum

# Initialize particles in phase space (x, y, z, px, py, pz)
particles = np.array([x, y, z, px, py, pz])
r_in0 = particles.reshape(6, 1000)

plt.plot(x, y, marker='o', ls='none')
# Track the particles through the lattice
#tracked_particles = at.track(lattice, r_in0, 1000, 0)
quad_positions = []
quad_lengths = []
quad_strengths = []
position = 0.0
for elem in range(len(lattice)//12): 
    position += lattice[elem].Length
    if isinstance(lattice[elem], at.Quadrupole):
        print(lattice[elem].FamName, lattice[elem].K,'   ', lattice[elem].Length)
        quad_positions.append(position- lattice[elem].Length/2)
        quad_lengths.append(lattice[elem].Length)
        quad_strengths.append(lattice[elem].K)
# Plot the quadrupole strengths as vertical lines
plt.plot( figsize=(14, 12))
for pos, length, strength in zip(quad_positions, quad_lengths, quad_strengths):
    plt.plot([pos, pos], [0, strength], color="k", label="Quadrupole Strength" if pos == quad_positions[0] else "")
    #plt.plot([pos - length / 2, pos + length / 2], [strength, strength], color="red", linestyle="--", label="Length of Quadrupole" if pos == quad_positions[0] else "")
    plt.axhline(0, color="black", linestyle=":", linewidth=1)

# Add labels and legend
plt.xlabel("s position [m]")
plt.ylabel("Quadrupole Strength (K)")
plt.title("Quadrupole Strengths and Lengths Along the Lattice")
plt.legend()
# Plot beta functions
plt.plot(figsize=(10, 15))
lattice.plot_beta(s_range=[0,len(lattice)//12])
#plt.grid(True)
