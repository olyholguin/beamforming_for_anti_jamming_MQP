# beamforming_for_anti_jamming_MQP

Matlab Beamforming Functions (most use the Phased Array System Toolbox)

Uniform Linear Array
- creates a ula object, computes its response with these properties:
- Element
- NumElements
- ElementSpacing
- ArrayAxis
- Taper
ula = phased.ULA
ula.Element.FrequencyRange

Uniform Rectangular Array
- creates a ura object with the following properties:
- Element
- Size
- ElementSpacing
- Lattice
- ArrayNormal
- Taper
ura = phased.URA
ura.Element.FrequencyRange

Phase Shift Beamformer
- creates a phase shift beamformer object with the following properties:
- SensorArray
- PropagationSpeed
- OperatingFrequency
- DirectionSource
- Direction
- NumPhaseShifterBits
- WeightsNormalization
- WeightsOutputPort
psbeamformer = phased.PhaseShiftBeamformer

Minimum Variance Distrotionless Response
- creates an mvdr object with the following properties:
- SensorArray
- PropagationSpeed
- OperatingFrequency
- DiagonalLoadingFactor
- TrainingInputPort
- DirectionSource
- Direction
- NumPhaseShifterBits
- WeightsOutputPort
mvdrbeamformer = phased.MVDRBeamformer
mvdrbeamformer.TrainingInputPort
mvdrbeamformer_selfnull.Direction

Linear Constraint Minimum Variance
- creates an lcmv object with the following properties:
- Constraint
- DesiredReponse
- DiagonalLoadingFactor
- TrainingInputPort
- WeightsOutputPort
lcmvbeamformer = phased.LCMVBeamformer
stv = phased.SteeringVector
lcmvbeamformer.Constraint
lcmvbeamformer.DesiredResponse

Other Useful Signal Functions
x = collectPlaneWave
Input: array object, incoming signal matrix, incoming signal angle matrix,
carrier frequency, propagation speed
Output: received signal matrix

rs = RandStream
- creates a random number stream with a specified algorithm and seed

pattern
- takes an object as input and plots based on filtered parameters
