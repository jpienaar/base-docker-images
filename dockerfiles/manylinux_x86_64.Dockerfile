# We build our portable linux releases on the manylinux (RHEL-based)
# images, with custom additional packages installed. We switch to
# new upstream versions as needed.
FROM quay.io/pypa/manylinux_2_28_x86_64@sha256:8ab319e0ecea2f642b2436dbf736993f1af3051186d2e2fd27ac79a461f47191

RUN yum install -y epel-release && \
    yum install -y ccache clang lld && \
    yum install -y capstone-devel tbb-devel libzstd-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

######## AMD ROCM #######
ARG ROCM_VERSION=5.2.1
ARG AMDGPU_VERSION=22.20.1
ARG RHEL_VERSION=8.6

# Install the ROCm rpms
RUN  echo -e "[ROCm]\nname=ROCm\nbaseurl=https://repo.radeon.com/rocm/yum/${ROCM_VERSION}/main\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/rocm.repo \
  && echo -e "[amdgpu]\nname=amdgpu\nbaseurl=https://repo.radeon.com/amdgpu/${AMDGPU_VERSION}/rhel/${RHEL_VERSION}/main/x86_64\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/amdgpu.repo \
  && yum install -y rocm-dev \
  && yum clean all

######## GIT CONFIGURATION ########
# Git started enforcing strict user checking, which thwarts version
# configuration scripts in a docker image where the tree was checked
# out by the host and mapped in. Disable the check.
# See: https://github.com/openxla/iree/issues/12046
# We use the wildcard option to disable the checks. This was added
# in git 2.35.3
RUN git config --global --add safe.directory '*'
