#include <cstdio>
#include "cpu.h"

#include "common.h"

namespace StreamCompaction {
    namespace CPU {
        using StreamCompaction::Common::PerformanceTimer;
        PerformanceTimer& timer()
        {
	        static PerformanceTimer timer;
	        return timer;
        }



        /**
         * CPU scan (prefix sum).
         * For performance analysis, this is supposed to be a simple for loop.
         * (Optional) For better understanding before starting moving to GPU, you can simulate your GPU scan in this function first.
         */
        void scan(int n, int *odata, const int *idata) {
	        timer().startCpuTimer();
            
			odata[0] = 0;
			for (int i = 1; i < n; i++) {
				odata[i] = odata[i - 1] + idata[i - 1];
			}

	        timer().endCpuTimer();
        }

		void scan_wo_timer(int n, int *odata, const int *idata) {
			odata[0] = 0;
			for (int i = 1; i < n; i++) {
				odata[i] = odata[i - 1] + idata[i - 1];
			}
		}

		void scan_incusive(int n, int *odata, const int *idata) {
			odata[0] = 0;
			for (int i = 1; i < n; i++) {
				odata[i] = odata[i - 1] + idata[i - 1];
			}
		}



        /**
         * CPU stream compaction without using the scan function.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithoutScan(int n, int *odata, const int *idata) {
	        timer().startCpuTimer();
            
			int  nRemains = 0;

			for (int i = 0; i < n; i++) {
				if (idata[i]) {
					odata[nRemains++] = idata[i];
				}
			}

	        timer().endCpuTimer();
			return nRemains;
			
        }

        /**
         * CPU stream compaction using scan and scatter, like the parallel version.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithScan(int n, int *odata, const int *idata) {
	        timer().startCpuTimer();
			
			int *temp = new int[n];
			for (int i = 0; i < n; i++) {
				temp[i] = (idata[i] != 0);
			}
			
			int *temp_scan = new int[n];
			scan_wo_timer(n, temp_scan, temp);
	
			int nRemains = 0;
			
			for (int i = 0; i < n; i++) {
				if (temp[i]) {
					odata[temp_scan[i]] = idata[i];
					nRemains++;
				}
			}
			
			delete[] temp, temp_scan;
			
			timer().endCpuTimer();
			return nRemains;
        }
    }
}
