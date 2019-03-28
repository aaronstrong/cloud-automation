#
# apt install a bunch of random stuff ...
#

include_recipe 'g3_dev_apt'

user 'gen3lab' do
  comment 'lab user'
  shell '/bin/bash'
  manage_home true
end

group 'gen3lab-docker' do
  action :manage
  group_name 'docker'
  members ['gen3lab']
  append true
end


execute 'g3-lab-setup' do
  cwd '/home/gen3lab'
  command <<-EOF
    (
      su gen3lab
      # command for installing Python goes here
      if [ ! -d ./compose-services ]; then
        git clone https://github.com/uc-cdis/compose-services.git
        cd ./compose-services
        bash ./creds_setup.sh
      fi
    )
    EOF
end

execute 'g3-lab-keys' do
  cwd '/tmp'
  # TODO - move the list of keys out to an attribute or databag ...
  command <<-EOF
(
  for dir in /home/ubuntu /home/gen3lab; do
    if [ -d "$dir" ]; then
      cd "$dir"
      if [ ! -f .ssh/authorized_keys ]; then
        mkdir -m 0700 -p .ssh
        touch .ssh/authorized_keys
        chown -R $(basename $dir): .ssh
        chmod -R 0700 .ssh
      fi
      (cat - <<EOM
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVaMgmgl/6HsX39JW4lAMvFQpKVOtraLYKKT4K/N2dlnLMTxN2tpH07bz1qOSZyE6ecCwyX4xEINRkwPaqXDvxhdULL5+neZsu/JLDHJE4S0MBBlJanxgwt6hhqfg1FazrOSay820Rg+jpu4m4LINKQCh9mDSyY6Oca3Uavv+lbrdQWVAKWyYuN9lSNVWBuU+KC3eAWQ0GGClENJ0WFbPwJN7FJlHMpWf2CjoTqAkwF1EilxBLqKnJzZsd0kL0K9AbZRxNVo2odRyaXUlgXdgGksG0VJ8JIePp8O9AxId35qPYLFl66bCRH8crY+2Oif4E8/GaOhaU5y5ejqRgsr2fsJakVG+2m5o7EbFXB47hZ67Os02hQBGKdpBBd1zvGGIYB1HcLUDLRbqW7qEvTXQu+E4LiCXK3ZyGGY0WMCDaFXwil4lCj5aFL7Uwsks7eT+f19wZjTYHg/BeRiQWSvysom5sJ5JEC9o0C2OneH+jWQIZFBNo+CaRVkEDyA1ir7Lr4z8TDDnpGahSkUrSo1Ab9n0z2e1Nvt+68aYvMIEZd0YYs0J/+QoUHTIjThFAXq/LTK1TblMz/NKvAfOVc4eNwTLcbAvaM6Pu8OiHUISxN0tPwVRXySSW0zOn9RoajOdXGHbAAnsc/dmd7L/3fsnhVQhKTrRUq81ctwHEFl6BtQ== ribeyre@uchicago.edu
ssh-dss AAAAB3NzaC1kc3MAAACBAPfnMD7+UvFnOaQF00Xn636M1IiGKb7XkxJlQfq7lgyzWroUMwXFKODlbizgtoLmYToy0I4fUdiT4x22XrHDY+scco+3aDq+Nug+jaKqCkq+7Ms3owtProd0Jj6AWCFW+PPs0tGJiObieci4YqQavB299yFNn+jusIrDsqlrUf7xAAAAFQCi4wno2jigjedM/hFoEFiBR/wdlwAAAIBl6vTMb2yDtipuDflqZdA5f6rtlx4p+Dmclw8jz9iHWmjyE4KvADGDTy34lhle5r3UIou5o3TzxVtfy00Rvyd2aa4QscFiX5jZHQYnbIwwlQzguCiF/gtYNCIZit2B+R1p2XTR8URY7CWOTex4X4Lc88UEsM6AgXIpJ5KKn1pK2gAAAIAJD8p4AeJtnimJTKBdahjcRdDDedD3qTf8lr3g81K2uxxsLOudweYSZ1oFwP7RnZQK+vVE8uHhpkmfsy1wKCHrz/vLFAQfI47JDX33yZmBLtHjjfmYDdKVn36XKZ5XrO66vcbX2Jav9Hlqb6w/nekBx2nbJaZnHwlAp70RU13gyQ== renukarya@Renukas-MacBook-Pro.local
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw48loSG10QUtackRFsmxYXd3OezarZLuT7F+bxKYsj9rx2WEehDxg1xWESMSoHxGlHMSWpt0NMnBC2oqRz19wk3YjE/LoOaDXZmzc6UBVZo4dgItKV2+T9RaeAMkCgRcp4EsN2Rw+GNoT2whIH8jrAi2HhoNSau4Gi4zyQ2px7xBtKdco5qjQ1a6s1EMqFuOL0jqqmAqMHg4g+oZnPl9uRzZao4UKgao3ypdTP/hGVTZc4MXGOskHpyKuvorFqr/QUg0suEy6jN3Sj+qZ+ETLXFfDDKjjZsrVdR4GNcQ/sMtvhaMYudObNgNHU9yjVL5vmRBCNM06upj3RHtVx0/L rpowell@rpowell.local
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJTr2yJtsOCsQpuKmqXmzC2itsUC1NAybH9IA3qga2Cx96+hMRLRs16vWTTJnf781UPC6vN1NkCJd/EVWD87D3AbxTF4aOKe3vh5fpsLnVI67ZYKsRl8VfOrIjB1KuNgBD1PrsDeSSjO+/sRCrIuxqNSdASBs5XmR6ZNwowF0tpFpVNmARrucCjSKqSec8VY2QneX6euXFKM2KJDsp0m+/xZqLVa/iUvBVplW+BGyPe+/ETlbEXe5VYlSukpl870wOJOX64kaHvfCaFe/XWH9uO+ScP0J/iWZpMefWyxCEzvPaDPruN+Ed7dMnePcvVB8gdX0Vf0pHyAzulnV0FNLL ssullivan@HPTemp
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6vuAdqy0pOwC5rduYmnjHTUsk/ryt//aJXwdhsFbuEFxKyuHsZ2O9r4wqwqsVpHdQBh3mLPXNGo2MZFESNEoL1olzW3VxXXzpujGHDd/F9FmOpnAAFz90gh/TM3bnWLLVWF2j7SKw68jUgijc28SnKRNRXpKJLv6PN9qq8OMHaojnEzrsGMb69lMT8dro1Yk71c4z5FDDVckN9UVL7W03+PE/dN6AtNWMlIEWlgm6/UA9Og+w9VYQnhEylxMpmxdO0SAbkIrr3EPC16kRewfovQLZJsw2KRo4EK62Xyjem/M1nHuJo4KpldZCOupxfo6jZosO/5wpKF1j8rF6vPLkHFYNwR62zTrHZ58NVjYTRF927kW7KHEq0xDKSr5nj9a8zwDInM/DkMpNyme4Jm3e4DOSQ3mP+LYG9TywNmf9/rVjEVwBBxqGRi27ex6GWcLm4XB58Ud3fhf5O5BDdkLYD1eqlJE5M4UG5vP5C9450XxW5eHUi/QK2/eV+7RijrEtczlkakPVO7JdWDZ44tX9sjkAlLSvgxkn4xZSdfqm/aJBIHUpoEitkZf9kgioZdDz2xmBDScG3c3g5UfPDrMvSTyoMliPo7bTIjdT/R1XV27V8ByrewwK/IkS70UkbIpE3GNYBUIWJBdNPpgjQ5scMOvhEIjts2z4KKq1mUSzdQ== zac
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOHPLoBC42tbr7YiQHGRWDOZ+5ItJVhgSqAOOb8bHD65ajen1haM2PUvqCrZ0p7NOrDPFRBlNIRlhC2y3VdnKkNYSYMvHUEwt8+V3supJBj2Tu8ldzpQthDu345/Ge4hqwp+ujZVRfjjAFaFLkMtqvlAXkj7a2Ip6ZZEhd8NcRq/mQET3eCaBR5/+BGzEMBVQGTSGYOY5rOkR8PNQiX+BF7qIX/xRHo8GCOztO4KmDLmaZV63ovQwr01PXSGEq/VGfHwXAvzX13IXTYE2gechEyudhRGZBbhayyaKD7VRoKzd4BZuuUrLCSpMDWBK/qtECcP4pCXW/0Wi2OCzUen3syh/YrOtJD1CUO+VvW6/8xFrcBeoygFW87hW08ncXLT/XxpgWeExJrTGIxjr4YzcsWPBzxI7/4SmKbaDSjx/RMX7x5WbPc5AZzHY17cKcpdc14weG+sm2OoKF5RqnFB/JpBaNxG+Zq8qYC/6h8fOzDWo5+qWKO/UlWaa3ob2QpG8qOBskoyKVG3ortQ04E04DmoaOiSsXoj0U0zaJnxpdF+a0i31RxQnjckTMEHH8Y2Ow8KIG45tzhJx9NbqSj9abk3yTzGA7MHvugQFpuTQ3gaorfG+A9RGUmx6aQNwXUGu+DWRF7lFeaPJt4CDjzbDUGP/b5KJkWK0DDAI61JfOew== fauzi@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCk0Z6Iy3mhEqcZLotIJd6j0nhq1F709M8+ttwaDKRg11kYbtRHxRv/ATpY8PEaDlaU3UlRhCBunbKhFVEdMiOfyi90shFp/N6gKr3cIzc6GPmobrSmpmTuHJfOEQB1i3p+lbEqI1aRj9vR/Ug/anjWd2dg+VBIi4kgX1hKVrEd1CHxySRYkIo+NTTwzglzEmcmp+u63sLjHiHXU055H5D6YwL3ussRVKw8UePpTeGO3tD+Y0ogyqByYdQWWTHckTwuvjIOTZ9T5wvh7CPSXT/je6Ddsq5mRqUopvyGKjHWaxO2s7TI9taQAvISE9rH5KD4hceRa81hzu3ZqZRw4in8IuSw5r8eG4ODjTEl0DIqa0C+Ui+MjSkfAZki0DjBf/HJbWe0c06MEJBorLjs9DHPQ5AFJUQqN7wk29r665zoK3zBdZG/JDXccZmptSMKVS02TxxzAON7oG66c9Kn7Vq6MBYcE3Sz7dxydm6PtvFIqij9KTfJdE+yw2o9seywB5yFfPkL63+hYZUaDFeJvvQSq5+7X2Cltn+F05J+EiORU5wO5oQWV01a2Yf6RT3o/728aYfaPjkdubwbCDWkdo8FaRqmK1NdQ8IoFprBjrhyDFwIXMEuVPrCJOUjL+ksXLPvYw2truiPfDxWxcvkVOAl4myfQOP4YqGmQ/IumYUbAw== thanhnd@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDwQs4DcxK5n6U4kgdclw2fQOyUJhCk62Fbi/Rf9olFnoL0kiO+vu7GHueUUYTKVJNi5+h5Uo6RY2Vw0HSCsv+YgjVG4Tkb5/fSgewyVOw3sUIbRc53id8nSgxJyIT209Rv08afFTVrT5coWOtpNC6QdSNAJQtv2vYTOU2957pJrryX0mkNYFHwXR5pWTHNoPRpUAj8vw5WCEFbFxM/5sNkRvo/kkF+wmRerCszuCVlSsVFw7PqRy/mrHu80Kkee9sxLQLLBui/Sz4vzM8AO0fUJVumLCXjdhgoYhVZWfHrZwNvdzaam6UZTKAGaTgMGtDgznTMm5plsHl8pYG0U02N5iyln92CD9gHUXSuD1VpFED5b1NU7yt8WfjFDmkTpYZgGxUT+01kG4xHy9Xf5zRkCpCHUcWZB6SxKMz0axN0DsDugbHt+sk5UrOOfM+pTfLE8STFVuknk6GhWVMRuXA5hq/cWYL5no3/W+RUMHSlnGAKf52nKFd1R+VMarMCY5aypviE/06zOplu2kbeLaGBauNVfjGGJZ3UNlCtZSuo2j8/noB+u4lZgvktVaW2rvRsEIHK4bcE28HeI04qLRsfaoN0Nz9MyEszX8LNys00JEBEXUIhDhKvH7q4qG+cnHARaz6pkDiDJ5s3Mkk/Qck9r2xUI+DleU4+x/sJtSNKcQ== ted.summer2@gmail.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+t+FKoTS4c+amC1EAD7uDC3YM54jaDtD6TAhSOw3mhXnS/erDvBUj/vgLlwx12Za8bDDtZyRzRSj3O3Tv51CUGLR1E6o/Y5olYN1pxW4Ftk24TiXHNEzyBqTViF3yosRBwjXSqRJq4Ooezoy5aHRciWQ6Y/DnARXH0MRh62ghgzzIMOUGOBN7nLn2KIh3hLCSFz7EAg7Dw/H80PvCT49XX8i5Nfs4GA/WV+3GPnQNOqahyw2B6jik7fWKLwmRFraIrWACll1SKs8sgPICgpNwDXOn+zTDOLedCLGCHRFrtNpdK+qsXhToyj2oxYyw4hdC1tWqLJhIEcm6M7eAM19N avantol@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwr7QDrMCalBC78pk5oXHgiyh20815E7QtE0pyOTb1PSX50VdJeXmmsQP6nYFDjIGow2+ckWQD1LbiCX24IEKYxknVujh9rG9yvaEaelSpDvpFu6owvPHye1yWgY3XVM9KGSSBWCzuNTcv9+KlM2LWUBbBn/xHEjmGhlrgJRE5YNHvKb7aRS8QNmAIN7BRpvHEv/rAQk0rizhx5BSIhH0OvbQqwfcyDC7lOvhYZgT8Lv0TPuFGrSxO6n3CRrhjG1ZjhePNik7MVgtXspyD+JWrR+n1t3zt44x+FWTnoAYVy1a0VZ3A4CJfCV5p2sxpkZ0yeOecBu6wLviVp7FwCN77G/zP9rJqstrQisrnHtFWiYzM0vpBBJG+dvHlqYf2xp5+UkUSwmrdLdUQAzxlx5uf/G1gens/LeM9zxuW1EtYsCQIIl33nvDAPxUdan3oolSKO+nBsLgXJbFX6yohw5fTEleURm0LqHQ0XTjPL57W3hhul5NOzHyn9iMh8li7EgBvLkwYR/hwzKjLVXvGxa1hiz4UnJy5Qd9gr7+DS3vK7YEzTjZxt8CQNex1E1keWTvws32FHzUcZ9t3MP6cK3gQQeu9tmNjU58PY+kQN1ShiWESXX6nGSKuuQixmwT3iiJ6/CqImozCGiESjQj3J9SzrWTG33XTJhnbEFub8zlnhQ== diw@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGCzWknkaGjKQlJiDZ8TaassavBOqh2fP8MJ0hgaFqavjGMZ9bT6VDT14rLECYRYHHybYk9vF+ZpTy3PhTdUq54z56y8ggxZ9RNd1Ne36asrCx5NJVwr81Un/kWh1m7sBqx/HX3jZhXxzpv2O5moJF1ApKRiqia/2X5cx+qNKubo2w7bdby9/1R4KGpghmoqLHVp9jLvgZltNvq6szbz6UqFDbHvSyJjaG04ob3sIPwsFYalzBVFyDUrd85mY2AG85DQ5NogjUxX37ACJe/qoR3HDGie+2RWv1RR9g72cHjRsQojAYgp/avq7obYSbF33dlM2tAz7qSVby8zkL92LTOt7/DX+8IJMkIn7xSVuOFkd1vx7RkwgtzLunzDAlxMcCzAbQpWPFhGDlItYLzMLj+Ctv9csgljHva4lgeNz8pGzKpv5xOTqAp1J0Cwe1GQAYw6GfG1IwIIKYUPfPtfXytJDnUu6dpgCttplxIlKWL32uhWyOZZ45iQRc7KHwG6IobBztv7KCmKIQ9EYuA2H+RFIv86SAtADDe44B/DCSLpeFZVQDHLzCuWhUWvRdn3EKdAu7+khsE2jRB0f12rXR0D7Zy5AmefNRmsUyQlbV3yCrFjUpWqeSfBgUvTgSqF6XgxtzIImNS+V+1uJqIazNwZO6LszpRREyT60Z9vDzOw== rudyardrichter@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCX+Tz7wVUpi00A/+Md+ndOBJPtASv4enTfA4eKDLAXME323Kro4vSLDo38SrJfPH3uYNVRDAKKH7jTi4eL4EbWQuoE7x/L2C9kz8yq047sWSQkpVkDugs4grG/yK/+D5rn+CvZb7c6qX3EKjyJ81p6/OJl2EdjHL6JCQw4Wnk97uUA5L64JeqzWWuhENtZS3Fgoa2lgSpcqiq517rCQqNTysG7dLCGE6m/DeiAWYaBs2QR3n7Jd9gyftmP1fMAvS3VEgPmTTK6KP+ewu2MA3Sx6Bg2JTSscFct5zQqya8u43r7qPiVqWsOrDZPrLh/cuDVP3h9VvICNpZsC8NlLaXNT0DtkRictfMNDIyARqw79OM1VwKJ4Jujp7sGtSDjeRWbqdN6+BsDfMv7WQ0Z+kiHhuAwtn6gWsJwmdcLaU0VPZ5owVnO2KRgHL260pOqK4xgZVPtoWlHDLUfrp2va1wJh4gJPgdWBTqu5mDhcSJdzC8pyOk4zIgjLWhg1vxJG3inVcJ5QBL5sbnzWUG+z/RGkjY6x93OncFYfdDdk9FnsUCelAnm/nAAPIDhwvnPRf1MmawClXU1/1NP4AEX8gkryjGPfC/5pFbd8hP2ocJGKeMRMX+XMPlPyqrX+Lg7IorleHsvqUxRKGosnXy/9uJCi0gsmHAW3zVTntxiMdhuNQ== zlchitty@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBFbx4eZLZEOTUc4d9kP8B2fg3HPA8phqJ7FKpykg87w300H8uTsupBPggxoPMPnpCKpG4aYqgKC5aHzv2TwiHyMnDN7CEtBBBDglWJpBFCheU73dDl66z/vny5tRHWs9utQNzEBPLxSqsGgZmmN8TtIxrMKZ9eX4/1d7o+8msikCYrKr170x0zXtSx5UcWj4yK1al5ZcZieZ4KVWk9/nPkD/k7Sa6JM1QxAVZObK/Y9oA6fjEFuRGdyUMxYx3hyR8ErNCM7kMf8Yn78ycNoKB5CDlLsVpPLcQlqALnBAg1XAowLduCCuOo8HlenM7TQqohB0DO9MCDyZPoiy0kieMBLBcaC7xikBXPDoV9lxgvJf1zbEdQVfWllsb1dNsuYNyMfwYRK+PttC/W37oJT64HJVWJ1O3cl63W69V1gDGUnjfayLjvbyo9llkqJetprfLhu2PfSDJ5jBlnKYnEj2+fZQb8pUrgyVOrhZJ3aKJAC3c665avfEFRDO3EV/cStzoAnHVYVpbR/EXyufYTh7Uvkej8l7g/CeQzxTq+0UovNjRA8UEXGaMWaLq1zZycc6Dx/m7HcZuNFdamM3eGWV+ZFPVBZhXHwZ1Ysq2mpBEYoMcKdoHe3EvFu3eKyrIzaqCLT5LQPfaPJaOistXBJNxDqL6vUhAtETmM5UjKGKZaQ== emalinowski@uchicago.edu
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWTOPbhawyQ/A5jKf+m7Aol1L8JN1xXtQAWBjuUF6ZiRYW1jmnujnjw2I++ILydjswqwqwYxURtDxwUvLcZDlrqDYYpvzjEaDB0B2gpldFo4hNDG+TreN8t0a93TcrQtV5duOEIuIMr0mAtvRapcLhu4mggsrNwrn3tlIWgMNdBHFSDWoxGeYvklY+Q+6YVa2let3HjTSbCh7bL+5O+kfs9H+D4f2oX3X0I41kE7yI61FIk3vvLmTQuG9ZVLOJbrg7Vr64QOwZtKuErF/FqRkNL8uxAEZkbJ9ZdRxh5mZQYddOoyODZiTRz8A5EQiTs9cEv1e8OrPIvIlmHnIyzlVywP5Twdu3Ak5nSswjXrCsNIoFOEneu4D7L+mo8icYfgVuXFwdU6eFfJIa1hx0mX8XLVwg5HV+0xqEv5jhkSsGAvD71PL9/aBKs/HVIaMcUgPGng0JKugD2cXRjKWCljh8BbzVJdSERwO/t72MnGV/boUG6COHGyHnuWEg9tbyBioi+2Kp4VYqr5+cmZoQKxHSq1cpWiuzpXtKsqENZncM+2cWVJ0CYIbCai8jBY8+4l5YZNLyVvf7mSPOcV8gJeIJrsoAv9MMOQCp0/vR6FwpEqW8Y4AQPxXdj4jAxwgyIRvKtEit+P7SxcNbhphI4cTij6I5qWA3McjL20mkmLT4Q== abgeorge@umich.edu
EOM
      ) | while read -r line; do
        key=$(echo $line | awk '{ print $3 }')
        if ! grep "$key" .ssh/authorized_keys > /dev/null 2>&1; then
          echo $line >> .ssh/authorized_keys
        fi
      done
    else
      echo "$dir does not exist"
    fi
  done
)
  EOF
end
