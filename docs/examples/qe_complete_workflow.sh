#!/bin/bash
# Complete Quantum ESPRESSO workflow for comprehensive materials analysis

echo "=== Complete Quantum ESPRESSO Workflow ==="
echo "Starting comprehensive calculations..."

# Step 1: SCF calculation
echo "Step 1: Running SCF calculation..."
scf_job_id=$(qsub qe_scf_job.sh | cut -d'.' -f1)
echo "SCF job submitted with ID: $scf_job_id"

# Wait for SCF to complete
echo "Waiting for SCF calculation to complete..."
while qstat $scf_job_id >/dev/null 2>&1; do
    sleep 60
    echo "SCF job still running..."
done

# Check if SCF completed successfully
if grep -q "JOB DONE" qe_scf.out; then
    echo "SCF calculation completed successfully!"
else
    echo "ERROR: SCF calculation failed!"
    exit 1
fi

# Step 2: Non-SCF calculation
echo "Step 2: Running non-SCF calculation..."
nscf_job_id=$(qsub qe_nscf_job.sh | cut -d'.' -f1)
echo "Non-SCF job submitted with ID: $nscf_job_id"

# Wait for non-SCF to complete
while qstat $nscf_job_id >/dev/null 2>&1; do
    sleep 60
    echo "Non-SCF job still running..."
done

if grep -q "JOB DONE" qe_nscf.out; then
    echo "Non-SCF calculation completed successfully!"
else
    echo "ERROR: Non-SCF calculation failed!"
    exit 1
fi

# Step 3: DOS calculation
echo "Step 3: Running DOS calculation..."
dos_job_id=$(qsub qe_dos_job.sh | cut -d'.' -f1)
echo "DOS job submitted with ID: $dos_job_id"

# Wait for DOS to complete
while qstat $dos_job_id >/dev/null 2>&1; do
    sleep 30
    echo "DOS job still running..."
done

if grep -q "JOB DONE" qe_dos.out; then
    echo "DOS calculation completed successfully!"
else
    echo "ERROR: DOS calculation failed!"
    exit 1
fi

# Step 4: Projected DOS calculation
echo "Step 4: Running projected DOS calculation..."
pdos_job_id=$(qsub qe_pdos_job.sh | cut -d'.' -f1)
echo "Projected DOS job submitted with ID: $pdos_job_id"

# Wait for projected DOS to complete
while qstat $pdos_job_id >/dev/null 2>&1; do
    sleep 30
    echo "Projected DOS job still running..."
done

if grep -q "JOB DONE" qe_pdos.out; then
    echo "Projected DOS calculation completed successfully!"
else
    echo "ERROR: Projected DOS calculation failed!"
    exit 1
fi

# Step 5: Band structure calculation
echo "Step 5: Running band structure calculation..."
bands_job_id=$(qsub qe_bands_job.sh | cut -d'.' -f1)
echo "Band structure job submitted with ID: $bands_job_id"

# Wait for band structure to complete
while qstat $bands_job_id >/dev/null 2>&1; do
    sleep 60
    echo "Band structure job still running..."
done

if grep -q "JOB DONE" qe_bands.out; then
    echo "Band structure calculation completed successfully!"
else
    echo "ERROR: Band structure calculation failed!"
    exit 1
fi

# Step 6: Phonon calculation
echo "Step 6: Running phonon calculation..."
phonon_job_id=$(qsub qe_phonon_job.sh | cut -d'.' -f1)
echo "Phonon job submitted with ID: $phonon_job_id"

# Wait for phonon to complete
while qstat $phonon_job_id >/dev/null 2>&1; do
    sleep 120
    echo "Phonon job still running..."
done

if grep -q "JOB DONE" qe_phonon.out; then
    echo "Phonon calculation completed successfully!"
else
    echo "ERROR: Phonon calculation failed!"
    exit 1
fi

# Step 7: Spin-orbit coupling calculation
echo "Step 7: Running spin-orbit coupling calculation..."
soc_job_id=$(qsub qe_soc_job.sh | cut -d'.' -f1)
echo "SOC job submitted with ID: $soc_job_id"

# Wait for SOC to complete
while qstat $soc_job_id >/dev/null 2>&1; do
    sleep 60
    echo "SOC job still running..."
done

if grep -q "JOB DONE" qe_soc.out; then
    echo "Spin-orbit coupling calculation completed successfully!"
else
    echo "ERROR: Spin-orbit coupling calculation failed!"
    exit 1
fi

echo "=== All calculations completed successfully! ==="
echo "Results available in:"
echo "  - Electronic DOS: dos.dat"
echo "  - Projected DOS: *.pdos files"
echo "  - Band structure: bands.dat"
echo "  - Phonon DOS: phonon_dos.dat"
echo "  - Phonon frequencies: phonon_frequencies.dat"
echo "  - SOC energies: soc_bands.dat"
echo "  - Wavefunctions: *.wfc* files"
echo "  - Charge density: *.charge-density.dat"

echo ""
echo "Next steps:"
echo "1. Run analysis scripts:"
echo "   python qe_band_analysis.py"
echo "   python qe_phonon_analysis.py"
echo "   python qe_soc_analysis.py"
echo "2. Generate plots and reports"
echo "3. Analyze results for publication" 